FilterExpander = require '../ecs/filter_expander'

class ViewSystem
  @Subscribe: null

  @createInstance: (args...) -> new @(args...)

  constructor: ->
    @componentFilters = FilterExpander.expandFilterGroups(@constructor.Subscribe)

  searchComponents: ->
    @entityFinder.search(@componentFilters)

  update: (ui, entityFinder) ->
    @ui = ui
    @entityFinder = entityFinder

    @process()

    @ui = null
    @entityFinder = null

  process: ->
    console.log "!! ViewSystem requires you to implement a process() method"

module.exports = ViewSystem

