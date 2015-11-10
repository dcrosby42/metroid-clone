Immutable = require 'immutable'
Debug = require '../utils/debug'

Debug.bencher.onLoop "filterObjects", (name, things, records) ->
  filterCalls = things.length
  totalComps = 0
  for {numComps,filter} in things
    totalComps += numComps
  avgComps = totalComps / filterCalls
  records.push filterCalls: filterCalls, compsFiltered: totalComps

# f0 looks like these:
#   { match: { type: 'animation' }, as: 'animation' }
#   { match: { type: 'position', eid: 'e2' }, as: 'position', join: 'animation.eid' }

searchWithJoins = (comps, filters,row=Immutable.Map()) ->
  if filters.size == 0
    return Immutable.List([row])

  f0 = expandLabel(expandJoins(filters.first(),row))
  fs = filters.shift()

  as = f0.get('as')
  filterObjects(comps,f0).map((c) ->
    searchWithJoins(comps,fs,row.set(as,c))
  ).flatten(1)

searchWithJoins2 = (componentsByCid, indices, filters, row=null) ->
  row ?= Immutable.Map()
  if filters.size == 0
    return Immutable.List([row])

  if !filters.first
    console.log "wtf?",filters
    throw "wtf?"
  f0 = expandLabel(expandJoins(filters.first(),row))
  fs = filters.shift()

  fmatch = f0.get('match')
  comps = if fmatch.has('eid')
    cids = indices.getIn(['eid',fmatch.get('eid')])
    cids.map (cid) -> componentsByCid.get(cid)
  else
    componentsByCid.toList()

  as = f0.get('as')
  filterObjects(comps,f0).map((c) ->
    searchWithJoins2(componentsByCid, indices, fs, row.set(as,c))
  ).flatten(1)

filterObjects = (comps,filter) ->
  Debug.bencher.notice "filterObjects", numComps:comps.size, filter:filter

  matchProps = filter.get('match')
  comps.filter (obj) ->
    matchProps.every (v,k) -> obj.get(k) == v

expandLabel = (filter) ->
  return filter if filter.get('as')?
  filter.set 'as', filter.get('match').first()
  
expandJoins = (filter,row) ->
  join = filter.get('join')
  if join?
    [refKey,key] = join.split('.')
    if val = row.getIn [refKey,key]
      filter.setIn ['match',key], val
    else
      filter
  else
    filter

module.exports =
  # search: (comps,indices,filters) ->
  #   searchWithJoins(comps.toList(),filters)
  search: searchWithJoins2
