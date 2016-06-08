EntitySearch = require './entity_search'

class BaseSystem
  @Subscribe: null

  constructor: ->
    @searcher = EntitySearch.prepare(@constructor.Subscribe)
    @processFn = @process.bind(@)
    # @_primaryComponentName = @constructor.ImplyEntity || @constructor.Subscribe[0]

  searchAndIterate: ->
    @searcher.run @estore, @processFn

  update: (@estore, @input, @eventBucket) ->
    @searchAndIterate() # TODO: it's presumptous to assume all systems are this wway.  Instead thus behavior should be pulled into a subclases, IteratingSystem, and many systems should inherit therefrom.  Once this is fixed, update ViewSystem and ViewMachine and ViewObjectSyncSystem

    @estore = null
    @input = null
    @eventBucket = null
    

  # SUBCLASSES MUST IMPLEMENT process(...) ->

  dt: ->
    @input.get('dt')

  #
  # EVENTS
  #

  getEvents: (eid) -> @eventBucket.getEventsForEntity(eid)

  getEvent: (eid,eventName) ->
    for event in @getEvents
      if event.name == eventName
        return event
    return null

  publishEvent: (eid,event,data=null) -> @eventBucket.addEventForEntity(eid,event,data)

  publishGlobalEvent: (event,data=null) -> @eventBucket.addGlobalEvent(event,data)
  
  handleEvents: (eid,handlerMap) ->
    @getEvents(eid).forEach (e) ->
      handlerMap[e.name]?(e.data)

  

module.exports = BaseSystem
