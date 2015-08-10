Common = require '../entity/components'
MathUtils = require '../../utils/math_utils'
StateMachineSystem = require '../../ecs/state_machine_system'

class SamusDamageSystem extends StateMachineSystem
  @Subscribe: [ "samus", "damaged", "velocity" ]

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
    console.log "SamusDamageSystem newState"
    @publishEvent 'hit'

  damageAction: ->
    console.log "SamusDamageSystem damageAction"
    # TODO: subtract HP
    
    @addComp Common.Timer.merge
      time: 300
      event: 'damageRecoilExpired'

    @addComp Common.Timer.merge
      time: 500
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


module.exports = SamusDamageSystem
