FilterExpander = require './filter_expander'

Debug = require '../utils/debug'

class EntityStoreFinder
  constructor: ->

  setEntityStore: (@estore) ->
  unsetEntityStore: () -> @estore = null

  search:      (filters) ->
    unless @estore
      console.log "!! EntityStoreFinder#search: estore not set"
      return null
    filters = Debug.imm(filters)
    expanded = FilterExpander.expandFilterGroups(filters)
    @estore.search expanded

  allComponentsByCid: ->
    unless @estore
      console.log "!! EntityStoreFinder#allComponentsByCid: estore not set"
      return null
    @estore.allComponentsByCid()

module.exports = EntityStoreFinder
