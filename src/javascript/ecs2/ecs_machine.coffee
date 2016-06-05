Immutable = require 'immutable'
EventBucket = require '../ecs/event_bucket'

class EcsMachine
  constructor: (@systems) ->
    @eventBucket = new EventBucket()

  update: (estore, input) ->
    @eventBucket.reset()

    for system in @systems
      system.update(estore, input, @eventBucket)

    return [estore,@eventBucket.globalEvents]

module.exports = EcsMachine

