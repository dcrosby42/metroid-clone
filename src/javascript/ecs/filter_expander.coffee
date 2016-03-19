Immutable = require 'immutable'
Map = Immutable.Map
List = Immutable.List

ObjectStoreSearch = require '../search/object_store_search'
EntityStore = require './entity_store2'

isString = (x) -> (typeof x) == 'string'

expandFilterGroups = (filterGroups) ->
  filterGroups = Immutable.fromJS(filterGroups)
  if List.isList(filterGroups.first())
    expandedGroups = filterGroups.flatMap (gr) -> expandFilters(gr, prefixGroup: true)
  else
    expandFilters filterGroups

expandFilters = (fs,opts=Map()) ->
  filters = Immutable.fromJS(fs)
  opts = Immutable.fromJS(opts)
  filters = filters.map(expandFilter)
  if opts.get('prefixGroup')
    filters = applyGroupPrefix(filters)
  filters = joinAll(filters, 'eid')
  filters = filters.map (filter) ->
    ObjectStoreSearch.convertMatchesToIndexLookups(filter, EntityStore.Indices)
  filters

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
    filter.set 'match', Map(type: m)
  else
    filter

expandLabel = (filter) ->
  return filter if filter.get('as')?
  if filter.hasIn(['match','type'])
    filter.set 'as', filter.getIn ['match','type']
  else
    filter.set 'as', filter.get('match').first()

applyGroupPrefix = (filters) ->
  return filters if filters.size <= 1

  first = filters.first()

  groupLabel = first.get('as')
  rest = filters.shift().map (f) ->
    f.update('as', (as) -> "#{groupLabel}-#{as}")

  rest.unshift(first)

joinAll = (filters,key) ->
  return filters if filters.size <= 1
  first = filters.first()
  join = List([first.get('as'), key])
  rest = filters.shift().map (f) -> f.setIn(['match',key], join)
  rest.unshift(first)

module.exports =
  expandFilterGroups: expandFilterGroups
  expandFilters: expandFilters
  expandFilter: expandFilter
  expandLabel: expandLabel
  joinAll: joinAll
