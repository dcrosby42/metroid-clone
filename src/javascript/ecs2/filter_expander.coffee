Immutable = require 'immutable'

isString = (x) -> (typeof x) == 'string'

expandFilters = (fs) ->
  joinAll(Immutable.fromJS(fs).map(expandFilter), 'eid')

expandFilter = (f) ->
  filter = if isString(f)
    stringToFilter(f)
  else
    Immutable.fromJS(f)

  expandLabel(expandMatch(filter))

stringToFilter = (str) ->
  Immutable.fromJS match: { type: str }

expandMatch = (filter) ->
  m = filter.get('match')
  if isString(m)
    filter.set 'match', Immutable.Map(type: m)
  else
    filter

expandLabel = (filter) ->
  return filter if filter.get('as')?
  if filter.hasIn(['match','type'])
    filter.set 'as', filter.getIn ['match','type']
  else
    filter.set 'as', filter.get('match').first()

joinAll = (filters,key) ->
  return filters if filters.size <= 1

  first = filters.first()
  join = "#{first.get('as')}.#{key}"
  
  rest = filters.shift().map (f) ->
    return f if f.has('join')
    f.set('join', join)

  rest.unshift(first)

module.exports =
  expandFilters: expandFilters
  expandFilter: expandFilter
  expandLabel: expandLabel
  joinAll: joinAll
