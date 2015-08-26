Common = require '../entity/components'
# MathUtils = require '../../utils/math_utils'
StateMachineSystem = require '../../ecs/state_machine_system'

class SamusDeathSystem extends StateMachineSystem
  @Subscribe: [ "death" ]

  @StateMachine:
    componentProperty: ['death','state']
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
    @publishEvent 'explode'

  explodeAction: ->
    @_makeDieSound()
    @addComp Common.Timer.merge
      time: 3000
      event: 'timesUp'

  gameOverAction: ->
    @destroyEntity()
    @publishGlobalEvent "Killed"

  _makeDieSound: ->
    @newEntity [
      Common.Sound.merge
        soundId: 'samus_die'
        volume: 0.15
        playPosition: 0
        timeLimit: 3000
    ]

module.exports = SamusDeathSystem
