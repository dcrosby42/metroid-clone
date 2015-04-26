FilterExpander = require './filter_expander'

Debug = require '../utils/debug'

class EntityStoreFinder
  constructor: (@estore) ->
  search:      (filters) ->
    filters = Debug.imm(filters)
    expanded = FilterExpander.expandFilters(filters)
    # Debug.scratch1("#{filters.toString()} ---- #{expanded.toString()}")
    @estore.search expanded

module.exports = EntityStoreFinder
