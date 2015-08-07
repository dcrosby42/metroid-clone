Immutable = require 'immutable'

class EventBucket
  constructor: ->
    @reset()

  reset: ->
    @entityEvents = Immutable.Map()
    @globalEvents = Immutable.List()

  getEventsForEntity: (eid) ->
    es = @entityEvents.get(eid) || Immutable.List()
    return es.concat(@globalEvents)

  addEventForEntity: (eid, event) ->
    es = @entityEvents.get(eid) || Immutable.List()
    @entityEvents = @entityEvents.set eid, es.push(event)

  addGlobalEvent: (event) ->
    @globalEvents = @globalEvents.push(event)

module.exports = EventBucket

