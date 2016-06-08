Immutable = require 'immutable'
EntityStore = require '../ecs/entity_store'
BaseSystem = require '../ecs2/base_system'

class ViewSystem extends BaseSystem
  # It's gopry that we have to use an alternate method; BaseSystem should actually not assume that all updates are meant to be component iterators calling out to process() once per match.
  updateView: (@estore, @uiState, @uiConfig) ->

    if @processAll?
      @processAll() # graphic item sync systems do this
    else if @process?
      @searchAndIterate() # more like normal systems

    @estore = null
    @uiState = null
    @uiConfig = null

module.exports = ViewSystem

