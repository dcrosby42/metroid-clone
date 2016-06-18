StateMachineSystem = require '../../ecs2/state_machine_system'
C = require '../../components'
T = C.Types

# MuzzleVelocity = 200/1000
# BulletLifetime = 50 / (200/1000)

class WeaponsSystem extends StateMachineSystem
  # @Subscribe: ['weapons', 'suit']
  @Subscribe: [ T.Weapons, T.Suit ]

  @StateMachine:
    componentProperty: [0,'state']
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
            condition:
              if: 'hasMissiles'
              then:
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
    # console.log "WeaponsSystem: fireBeam"
    @publishEvent @eid, 'fireBeam'

  fireBeamReleasedAction: ->
    # console.log "WeaponsSystem: fireBeamReleased"
    @publishEvent @eid, 'fireBeamReleased'


  hasMissilesCondition: ->
    missileLauncher = @entity.get(T.MissileLauncher)
    return missileLauncher? and missileLauncher.count > 0

  switchToMissilesAction: ->
    @publishEvent @eid, 'fireBeamReleased'
    console.log "WeaponsSystem: switchToMissiles"

  # missilesState: ->
    # missiles = @getEntityComponent(@eid(), 'missile_launcher')
    # if missiles? and missiles.get('count') > 0
    #   #
    # else
    #   console.log "WeaponsSystem: no missiles, switching back"
    #   @publishEvent 'cycleWeapon'
    #
  fireMissileAction: ->
    console.log "WeaponsSystem: fireMissile"
    @publishEvent @eid, 'fireMissile'

  fireMissileReleasedAction: ->
    # console.log "WeaponsSystem: fireMissileRelased"
    @publishEvent @eid, 'fireMissileReleased'

  switchToBeamAction: ->
    @publishEvent @eid, 'fireMissileReleased'
    # console.log "WeaponsSystem: switchToBeam"

module.exports = -> new WeaponsSystem()
