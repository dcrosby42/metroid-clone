Common = require '../../components'
Immutable = require 'immutable'
StateMachineSystem = require '../../../../ecs/state_machine_system'

class PowerupCelebrationSystem extends StateMachineSystem
  @Subscribe: ['powerup_celebration']

  @StateMachine:
    componentProperty: ['powerup_celebration','state']
    start: 'ready'
    states:
      ready:
        events:
          started:
            action: 'celebrate'
            nextState: 'celebrating'
      celebrating:
        events:
          finished:
            action:    'exit'
            nextState: 'done'

  readyState: ->
    @publishEvent 'started'

  celebrateAction: ->
    @addComp Common.Sound.merge
      soundId: 'powerup_jingle'
      volume: 0.5
      playPosition: 0
      timeLimit: 4500
    @addComp Common.Timer.merge
      time: 4500
      event: 'finished'

  exitAction: ->
    @destroyEntity()
    @publishGlobalEvent 'PowerupCelebrationDone'


module.exports = PowerupCelebrationSystem

