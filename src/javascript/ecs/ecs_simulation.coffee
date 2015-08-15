Immutable = require 'immutable'
EventBucket = require './event_bucket'

class EcsSimulation
  constructor: ({systems}) ->
    @systems = Immutable.List(systems)
    @systemInstances = @systems.map (s) -> s.Instance()

    @eventBucket = new EventBucket()

  update: (estore, input) ->
    @eventBucket.reset()

    @systemInstances.forEach (s) =>
      s.update(estore, input, @eventBucket)

    null

module.exports = EcsSimulation

