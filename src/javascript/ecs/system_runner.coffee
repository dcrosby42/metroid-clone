Immutable = require 'immutable'

searchAndUpdate = (system, estore, input, entityUpdater,eventBucket) ->
  filters = system.getIn ['config','filters']
  update = system.get 'update'
  estore.search(filters).forEach (result) ->
    update(result,input,entityUpdater,eventBucket)

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

class SystemRunner
  constructor: (@estore, @entityUpdater, @systems) ->
    @eventBucket = new EventBucket()
    # @systems.forEach (system) ->
    #   console.log "System: #{system.getIn(['config','filters']).toString()}"

  run: (input) ->
    @eventBucket.reset()
    if input.get('dt') > 0
      @eventBucket.addGlobalEvent('time')

    @systems.forEach (system) =>
      switch system.get('type')
        when 'iterating-updating'
          searchAndUpdate system, @estore, input, @entityUpdater, @eventBucket
          
        else
          console.log "!! CAN'T RUN SYSTEM OF TYPE: #{system.get('type')} - #{system.toString()}"

module.exports = SystemRunner

