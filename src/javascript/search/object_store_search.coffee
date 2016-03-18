Immutable = require 'immutable'
Profiler = require '../profiler'
ObjectStore = require './object_store'

debug = ->        # debugging disabled
# debug = console.log # debugging enabled

expandPlaceholder = (x,row) ->
  if Immutable.List.isList(x)
    row.getIn(x)
  else
    x
expandMatch = (filter,row) ->
  if filter.has('match')
    filter.update 'match', (m) ->
      m.map (v) -> expandPlaceholder(v,row)
  else
    filter

expandLookup = (filter,row) ->
  if filter.has('lookup')
    filter.update 'lookup', (l) ->
      l.update 'keypath', (kp) ->
        kp.map (v) -> expandPlaceholder(v,row)
  else
    filter

  
keysInMatch = (match) ->
  keys = match.keySeq().toSet()
  if join = match.get('join')
    keys = keys.add('eid')
  keys

cleanupEmptyMap = (key,map) ->
  if Immutable.is(Immutable.Map(), map.get(key))
    map.remove(key)
  else
    map

convertMatchesToIndexLookups = (filter,store) ->
  match = filter.get('match')
  if index = ObjectStore.bestIndexForKeys(store,keysInMatch(match))
    cleanupEmptyMap 'match', filter.set('lookup', Immutable.Map(
      index: index
      keypath: index.map (key) -> match.get(key)
    )).update('match', (match) ->
      index.reduce (m,k) ->
        m.remove(k)
      , match
    )
  else
    filter
    
# {
#   as: 'animation'
#   match:
#     mode: ['bullet','mode']
#   lookup:
#     index: ['eid', 'type']
#     keypath: [['bullet','eid'], 'animation']
# }

search = (object_store,filters,row=Immutable.Map()) ->
  search_logCall(object_store,filters,row)
  if filters.size == 0
    return Immutable.List([row])

  f0 = filters.first()
  f0 = expandLookup(expandMatch(f0,row), row)
  rest = filters.shift()

  as = f0.get('as')
  throw new Error("Filter must be labeled via 'as': #{f0.toJS()}") unless as?

  #
  # First: narrow the results by applying an indexed lookup (if available).
  #
  objs = if lookup = f0.get('lookup')
    index = lookup.get('index')
    keypath = lookup.get('keypath')
    search_logIndex(index,keypath)
    ObjectStore.getIndexedObjects(object_store, index, keypath)
  else
    # No indexed lookup available; we must scan all objects
    ObjectStore.allObjects(object_store)

  #
  # Second: apply any non-indexed match criteria to the objectset
  # 
  if matchProps = f0.get('match')
    search_logFilter(objs,matchProps)
    # PRESUMABLY, THIS IS THE EXPENSIVE PART.
    # The following (potentially mutli-field) comparison (matchProps.every) is run once
    # per existing component.  
    # Many systems join at least two component types.
    # A certain subset of systems really only expect to hit one main match.  (Eg, ['samus','map'])
    # Full-list-scans mean joins are worst-case exponential.
    # n + n(c1) + n(c2) + ...n(cJ-1) where n = num components, h1 = number of hits in col1, h2 = number of hits in col2, and J is the number of cols being joined
    # 10 comps, 2 joined cols, 3 hits in the first col: 10 + 10(3) = 40 comparisons to yield 3 results. 
    objs = objs.filter (obj) ->
      matchProps.every (v,k) -> obj.get(k) == v

  if objs.size == 0 and f0.get('optional',false) == true
    objs = Immutable.List([null])

  #
  # Recurse / join
  #

  objs.map((c) ->
    if rest.size == 0
      Immutable.List([row.set(as,c)])
    else
      search(object_store,rest,row.set(as,c))
  ).flatten(1)

search_logCall = (object_store,filters,row) ->
  Profiler.count("search")
  debug "search: invoked w filters",filters,row.toJS()

search_logIndex = (index,keypath) ->
  Profiler.count("search_index")
  debug "  search: using index:",index.toJS(), "with keypath",keypath.toJS()

search_logFilter = (objs,matchProps) ->
  Profiler.count("filterObjects")
  Profiler.sample("filterObjects_numComps",objs.size)
  debug "  search: filtering #{objs.size} objs by matching:", matchProps.toJS()

module.exports =
  search: (objectStore, filters) -> search objectStore, filters
  convertMatchesToIndexLookups: convertMatchesToIndexLookups
  _expandMatch: expandMatch
  _expandLookup: expandLookup
