Common = require '../../components'
Immutable = require 'immutable'
StateMachineSystem = require '../../../../ecs/state_machine_system'

MuzzleVelocity = 200/1000
BulletLifetime = 50 / (200/1000)

class WeaponsSystem extends StateMachineSystem
  @Subscribe: ['weapons', 'suit']

  @StateMachine:
    componentProperty: ['weapons','state']
    start: 'beam'
    states:
      beam:
        events:
          gunTrigger:
            action:    'fireBeam'
            nextState: 'beam'
          gunTriggerReleased:
            action:    'fireBeamReleased'
            nextState: 'beam'
          cycleWeapon:
            action:    'switchToMissiles'
            nextState: 'missiles'
      missiles:
        events:
          gunTrigger:
            action:    'fireMissile'
            nextState: 'missiles'
          gunTriggerReleased:
            action:    'fireMissileReleased'
            nextState: 'missiles'
          cycleWeapon:
            action:    'switchToBeam'
            nextState: 'beam'

  fireBeamAction: ->
    console.log "WeaponsSystem: fireBeam"
    @publishEvent 'fireBeam'

  fireBeamReleasedAction: ->
    console.log "WeaponsSystem: fireBeamReleased"
    @publishEvent 'fireBeamReleased'

  switchToMissilesAction: ->
    @publishEvent 'fireBeamReleased'
    console.log "WeaponsSystem: switchToMissiles"

  missilesState: ->
    missiles = @getEntityComponent(@eid(), 'missile_launcher')
    if missiles? and missiles.get('count') > 0
      #
    else
      console.log "WeaponsSystem: no missiles, switching back"
      @publishEvent 'cycleWeapon'

  fireMissileAction: ->
    console.log "WeaponsSystem: fireMissile"
    @publishEvent 'fireMissile'

  fireMissileReleasedAction: ->
    console.log "WeaponsSystem: fireMissileRelased"
    @publishEvent 'fireMissileReleased'

  switchToBeamAction: ->
    @publishEvent 'fireMissileReleased'
    console.log "WeaponsSystem: switchToBeam"

module.exports = WeaponsSystem
