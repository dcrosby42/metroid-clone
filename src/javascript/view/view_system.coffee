Immutable = require 'immutable'
EntityStore = require '../ecs/entity_store'

class ViewSystem
  @Subscribe: null

  @createInstance: (args...) -> new @(args...)

  constructor: ->
    if @constructor.Subscribe?
      @componentFilters = EntityStore.expandSearch(@constructor.Subscribe)
      # console.log "ViewSystem @Subscribe=#{@constructor.Subscribe} -> ",@componentFilters.toJS()

  searchComponents: ->
    if @componentFilters?
      @entityFinder.search(@componentFilters)
    else
      Immutable.List()

  update: (uiState, entityFinder, uiConfig) ->
    @ui = uiState
    @entityFinder = entityFinder
    @config = uiConfig

    @process()

    @ui = null
    @entityFinder = null
    @config = null

  process: ->
    throw new Error("ViewSystem requires you to implement a process() method")

module.exports = ViewSystem

