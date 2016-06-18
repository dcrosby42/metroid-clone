StateMachineSystem = require '../../ecs2/state_machine_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'

class SamusDeathSystem extends StateMachineSystem
  @Subscribe: [ T.Death ]

  @StateMachine:
    componentProperty: [0,'state']
    start: 'new'
    states:
      new:
        events:
          explode:
            action: 'explode'
            nextState: 'decomposing'
      decomposing:
        events:
          timesUp:
            action: 'gameOver'
            nextState: 'done'

      done: {}

  newState: ->
    @publishEvent @eid, 'explode'

  explodeAction: ->
    # TODO: explosion 
    @entity.addComponent Prefab.soundComponent
      soundId: 'samus_die'
      volume: 0.5
      playPosition: 0
      timeLimit: 3000
    @entity.addComponent Prefab.timerComponent
      time: 3000
      eventName: 'timesUp'

  gameOverAction: ->
    @entity.destroy()
    @publishGlobalEvent "Killed"


module.exports = -> new SamusDeathSystem()
