Common = require '../entity/components'
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
      time: 200
      event: 'damageRecoilExpired'

    @addComp Common.Timer.merge
      time: 400
      event: 'damageGracePeriodExpired'

  recoilingState: ->
    @updateProp 'velocity', 'x', (x) => x + @getProp('damaged','impulseX')
    @updateProp 'velocity', 'y', (y) => y + @getProp('damaged','impulseY')

  backToNormalAction: ->
    @addComp Common.Vulnerable
    @deleteComp @getComp('damaged')


module.exports = SamusDamageSystem
