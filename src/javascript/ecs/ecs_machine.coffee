Immutable = require 'immutable'
EventBucket = require './event_bucket'
EntityStore = require './entity_store'

class EcsMachine
  constructor: ({systems}) ->
    @systemDefs = systems
    @systems = Immutable.List(@systemDefs).map (s) -> s.Instance()

    @eventBucket = new EventBucket()
    @estore = new EntityStore()

  # update: (estore, input) ->
  #   @eventBucket.reset()
  #
  #   @systems.forEach (system) =>
  #     system.update(estore, input, @eventBucket)
  #
  #   return [estore,@eventBucket.globalEvents]

  update2: (state, input) ->
    @eventBucket.reset()
    @estore.restoreSnapshot(state)

    @systems.forEach (system) =>
      system.update(@estore, input, @eventBucket)

    events = @eventBucket.globalEvents
    state1 = @estore.takeSnapshot()
    return [state1, events]

module.exports = EcsMachine

