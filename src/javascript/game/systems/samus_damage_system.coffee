Common = require '../entity/components'
MathUtils = require '../../utils/math_utils'
StateMachineSystem = require '../../ecs/state_machine_system'

class SamusDamageSystem extends StateMachineSystem
  @Subscribe: [ "samus", "health", "damaged", "velocity" ]

  @StateMachine:
    componentProperty: ['damaged','state']
    start: 'new'
    states:
      new:
        events:
          hit:
            action: 'damage'
            nextState: 'recoiling'
      recoiling:
        events:
          damageRecoilExpired:
            nextState: 'gracePeriod'

      gracePeriod:
        events:
          damageGracePeriodExpired:
            action: 'backToNormal'
            nextState: 'done'
      done: {}

  newState: ->
    @publishEvent 'hit'

  damageAction: ->
    damage = @getProp('damaged','damage')
    @updateProp 'health', 'hp', (hp) => hp - damage
    @_makeHurtSound()
    if @getProp('health', 'hp') < 0
      @_startBeingDead()

    else
      @_makeHurtSound()

      @addComp Common.Timer.merge
        time: 300
        event: 'damageRecoilExpired'

      @addComp Common.Timer.merge
        time: 750
        event: 'damageGracePeriodExpired'

  recoilingState: ->
    @updateProp 'velocity', 'x', (x) =>
      MathUtils.clamp(
        x + @getProp('damaged','impulseX'),
        # -0.15, 0.15)
        -0.088, 0.088)

    @updateProp 'velocity', 'y', (y) =>
      MathUtils.clamp(
        y + @getProp('damaged','impulseY'),
        -0.1, 0.2)

  backToNormalAction: ->
    @addComp Common.Vulnerable
    @deleteComp @getComp('damaged')

  _makeHurtSound: ->
    @newEntity [
      Common.Sound.merge
        soundId: 'samus_hurt'
        # volume: 0.15
        volume: 0.2
        playPosition: 0
        timeLimit: 170
    ]

  _startBeingDead: ->
    @destroyEntity()
    @newEntity [
      Common.Sound.merge
        soundId: 'samus_die'
        # volume: 0.15
        volume: 0.5
        playPosition: 0
        timeLimit: 3000
      Common.Death
    ]


module.exports = SamusDamageSystem
