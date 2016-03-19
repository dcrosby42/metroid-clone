Immutable = require 'immutable'
FilterExpander = require '../ecs/filter_expander'

class ViewSystem
  @Subscribe: null

  @createInstance: (args...) -> new @(args...)

  constructor: ->
    if @constructor.Subscribe?
      @componentFilters = FilterExpander.expandFilterGroups(@constructor.Subscribe)
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

