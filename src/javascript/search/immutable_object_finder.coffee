Immutable = require 'immutable'
Profiler = require '../profiler'

#  { match: { type: 'position' }, join: "animation.eid" }
#  { match: { type: 'position' }, join: "animation.eid", as: 'animation_position' }
#  { match: { type: 'position', eid: 'e42' } as: 'animation_position' }, 
searchWithJoins = (comps,filters,row=Immutable.Map()) ->
  if filters.size == 0
    return Immutable.List([row])

  f0 = expandLabel(expandJoins(filters.first(),row))
  fs = filters.shift()

  as = f0.get('as')
  filterObjects(comps,f0).map((c) ->
    searchWithJoins(comps,fs,row.set(as,c))
  ).flatten(1)

filterObjects = (comps,filter) ->
  Profiler.count("filterObjects")
  Profiler.sample("filterObjects_numComps",comps.size)
  matchProps = filter.get('match')
  comps.filter (obj) ->
    matchProps.every (v,k) -> obj.get(k) == v

expandLabel = (filter) ->
  return filter if filter.get('as')?
  filter.set 'as', filter.get('match').first()
  
expandJoins = (filter,row) ->
  join = filter.get('join')
  if join?
    [refKey,key] = join.split('.') # TODO: update filter_expander#joinAll to express joins with a 2-vector instead of a string, so we don't have to split on "."
    if val = row.getIn [refKey,key]
      filter.setIn ['match',key], val
    else
      filter
  else
    filter


module.exports =
  search: (objects, filterSet) ->
    searchWithJoins Immutable.List(objects), Immutable.fromJS(filterSet)
