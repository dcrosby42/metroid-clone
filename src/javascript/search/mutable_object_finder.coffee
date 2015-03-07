Immutable = require 'immutable'
_ = require 'lodash'

search = (objects,filters,row=Immutable.Map()) ->
  if filters.size == 0
    return Immutable.List([row])

  f0 = expandLabel expandJoins(filters.first(), row)
  fs = filters.shift()
    
  as = f0.get('as')

  filterObjects(objects,f0).map((c) ->
    search objects, fs, row.set(as,c)
  ).flatten(1)
 
filterObjects = (objects,filter) ->
  matchProps = filter.get('match').toJS()
  objects.filter _.matches(matchProps)

expandLabel = (filter) ->
  return filter if filter.get('as')?
  filter.set 'as', filter.get('match').first()

expandJoins = (filter,row) ->
  join = filter.get('join')
  if join?
    [refKey,key] = join.split('.')
    refObj = row.get(refKey)
    if refObj
      if val = refObj[key]
        filter.setIn ['match',key], val
      else
        filter
    else
      filter
  else
    filter

module.exports =
  search: (objects, filterSet) ->
    search(
      Immutable.List(objects),
      Immutable.fromJS(filterSet)
    ).toJS()
