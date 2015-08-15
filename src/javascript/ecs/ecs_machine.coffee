Immutable = require 'immutable'
EventBucket = require './event_bucket'

class EcsMachine
  constructor: ({systems}) ->
    @systemDefs = systems
    @systems = Immutable.List(@systemDefs).map (s) -> s.Instance()

    @eventBucket = new EventBucket()

  update: (estore, input) ->
    @eventBucket.reset()

    @systems.forEach (system) =>
      system.update(estore, input, @eventBucket)

    null

module.exports = EcsMachine

