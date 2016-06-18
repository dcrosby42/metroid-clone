StateMachineSystem = require '../../ecs2/state_machine_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'
# Common = require '../../components'
# Immutable = require 'immutable'
# StateMachineSystem = require '../../../../ecs/state_machine_system'

class PowerupCelebrationSystem extends StateMachineSystem
  @Subscribe: [T.PowerupCelebration]

  @StateMachine:
    componentProperty: [0,'state']
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
    @publishEvent @eid, 'started'

  celebrateAction: ->
    @entity.addComponent Prefab.soundComponent
      soundId: 'powerup_jingle'
      volume: 0.5
      playPosition: 0
      timeLimit: 4500
    @entity.addComponent Prefab.timerComponent
      time: 4500
      eventName: 'finished'

  exitAction: ->
    @entity.destroy()
    @publishGlobalEvent 'PowerupCelebrationDone'


module.exports = -> new PowerupCelebrationSystem()

