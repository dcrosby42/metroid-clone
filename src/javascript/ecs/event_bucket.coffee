Immutable = require 'immutable'

mkEvent = (name,data) ->
  Immutable.fromJS
    name: name
    data: data

class EventBucket
  constructor: ->
    @reset()

  reset: ->
    @entityEvents = Immutable.Map()
    @globalEvents = Immutable.List()

  getEventsForEntity: (eid) ->
    es = @entityEvents.get(eid) || Immutable.List()
    return es.concat(@globalEvents)

  addEventForEntity: (eid, event, data=null) ->
    es = @entityEvents.get(eid) || Immutable.List()
    @entityEvents = @entityEvents.set eid, es.push(mkEvent(event,data))

  addGlobalEvent: (event,data=null) ->
    @globalEvents = @globalEvents.push(mkEvent(data))

module.exports = EventBucket

