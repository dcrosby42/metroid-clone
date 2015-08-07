Immutable = require 'immutable'
EventBucket = require './event_bucket'

searchAndUpdate = (system, estore, input, entityUpdater,eventBucket) ->
  filters = system.getIn ['config','filters']
  update = system.get 'update'
  estore.search(filters).forEach (result) ->
    update(result,input,entityUpdater,eventBucket)

processNewStyleSystem = (systemClass, estore, input, entityUpdater, eventBucket) ->
  system = systemClass.Instance()
  filters = system.componentFilters
  estore.search(filters).forEach (comps) ->
    system.handleUpdate(comps, input, entityUpdater, eventBucket)

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
      if Immutable.Map.isMap(system)
        switch system.get('type')
          when 'iterating-updating'
            searchAndUpdate system, @estore, input, @entityUpdater, @eventBucket
          else
            console.log "!! CAN'T RUN SYSTEM OF TYPE: #{system.get('type')} - #{system.toString()}"
      else
        # Assume new-style system classes:
        processNewStyleSystem(system, @estore, input, @entityUpdater, @eventBucket)


module.exports = SystemRunner

