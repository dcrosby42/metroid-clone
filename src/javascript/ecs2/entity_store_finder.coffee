FilterExpander = require './filter_expander'

Debug = require '../utils/debug'

class EntityStoreFinder
  constructor: (@estore) ->
  search:      (filters) ->
    filters = Debug.imm(filters)
    expanded = FilterExpander.expandFilterGroups(filters)
    @estore.search expanded

  allComponentsByCid: -> @estore.allComponentsByCid()

module.exports = EntityStoreFinder
