Immutable = require 'immutable'
Profiler = require '../profiler'

filterObjects = (comps,filter) ->
  Profiler.count("filterObjects")
  if !filter.has('match')
    Profiler.sample("filterObjects_numComps",0)
    return comps

  Profiler.sample("filterObjects_numComps",comps.size)
  matchProps = filter.get('match')
  comps.filter (obj) ->
    matchProps.every (v,k) -> obj.get(k) == v

expandLabel = (filter) ->
  return filter if filter.get('as')?
  filter.set 'as', filter.get('match').first()
  
expandPlaceholder = (x, row) ->
  if x.isList()
    row.getIn(x)
  else
    x

expandMatch = (filter,row) ->
  return filter unless filter.get('hasPlaceholders')
  # expand placeholders in match:
  filter.update 'match', (match) ->
    match.map (mval) -> expandPlaceholder(mval, row)

expandLookup = (filter,row) ->
  return filter unless filter.get('lookup')
  filter.update 'lookup', (lookup) ->
    lookup.update 'keyPath', (keyPath) ->
      keyPath.map (val) -> expandPlaceholder(val, row)

expandMatchAndLookup = (filter,row) ->
  expandLookup(expandMatch(filter, row))

    
# {
#   as: 'animation'
#   match:
#     mode: ['bullet','mode']
#   hasPlaceholders: true
#   lookup:
#     index: ['eid', 'type']
#     keyPath: [['bullet','eid'], 'animation']
# }
# {
#   as: 'animation'
#   match:
#     eid: ['bullet','eid']
#     type: 'animation'
#   hasPlaceholders: true
# }
# {
#   as: 'animation'
#   lookup:
#     index: ['eid', 'type']
#     keyPath: [['bullet','eid'], 'animation']
# }

lookupObjects = (store,filter) ->
  if lookup = filter.get('lookup')
    ObjectStore.getIndexedObjects(store, lookup.get('index'), lookup.get('keypath'))
  else
    ObjectStore.allObjects(store)

search = (object_store,filters,row=Immutable.Map()) ->
  if filters.size == 0
    return Immutable.List([row])

  f0 = expandLabel(expandMatchAndLookup(filters.first(),row))

  fs = filters.shift()

  as = f0.get('as')
  objs = lookupObjects(object_store,f0)
  filterObjects(lookupObjects(object_store,f0), f0).map((c) ->
    searchWithPlaceholdersAndIndexes(object_store,fs,row.set(as,c))
  ).flatten(1)


module.exports =
  search: (objectStore, filters) -> search objectStore, filters
