Common = require '../../components'
Immutable = require 'immutable'
StateMachineSystem = require '../../../../ecs/state_machine_system'

MuzzleVelocity = 200/1000
BulletLifetime = 50 / (200/1000)

class MissileLauncherSystem extends StateMachineSystem
  @Subscribe: ['missile_launcher', 'samus', 'position']

  @StateMachine:
    componentProperty: ['missile_launcher','state']
    start: 'ready'
    states:
      ready:
        events:
          fireMissile:
            action:    'shoot'
            nextState: 'coolDown'
      coolDown:
        events:
          fireMissileReleased:
            action:    'reset'
            nextState: 'ready'
          missileCooldownComplete:
            nextState: 'repeating'
      repeating:
        events:
          keepFiring:
            action: 'repeat'
            nextState: 'coolDown'
          fireMissileReleased:
            action: 'reset'
            nextState: 'ready'

  shootAction: ->
    @_fireMissile()
    @_startCooldown(500)

  repeatingState: ->
    @publishEvent 'keepFiring'

  repeatAction: ->
    @_fireMissile()
    @_startCooldown(150)

  resetAction: ->
    # Clear cooldown timer(s):
    @getEntityComponents(@eid(), 'timer', 'name', 'missileCooldown').forEach (comp) =>
      @deleteComp comp

  repeatState: ->
    @publishEvent 'done'
  

  _fireMissile: ->
    dir = @getProp('samus','direction')
    shootUp = @getProp('samus','aim') == 'up'

    missileLauncher = @getComp('missile_launcher')
    count = missileLauncher.get('count')
    if count <= 0
      return
    count -= 1
    @updateComp missileLauncher.set('count',count)

    pos = @getComp('position')
    @newEntity newMissile(missileLauncher,pos,dir,shootUp)

  _startCooldown: (ms) ->
    @addComp Common.Timer.merge
      time: ms
      event: 'missileCooldownComplete'
      name: 'missileCooldown'


newMissile = (weapon, position,direction,shootUp) ->
  offsetX = offsetY = vx = vy = 0

  animState = direction
  if shootUp
    offsetX = 2.5
    offsetY = -37
    vx = 0
    vy = -MuzzleVelocity
    if direction == 'left'
      offsetX = -3
    animState = "up"
  else
    offsetX = 13
    offsetY = -20
    vx = MuzzleVelocity
    vy = 0
    if direction == 'left'
      offsetX = -offsetX
      vx = -vx

  fireX = position.get('x') + offsetX
  fireY = position.get('y') + offsetY

  return [
    Common.Name.set 'name', 'missile'
    Common.Missile
      # damage: weapon.get('damage')
    Common.Animation.merge
      layer: 'creatures'
      spriteName: 'missile'
      state: animState

    Common.Position.merge
      x: fireX
      y: fireY
      direction: direction
    Common.Velocity.merge
      x: vx
      y: vy
    Common.MapCollider
    Common.HitBox.merge
      width: 4
      height: 4
      anchorX: 0.5
      anchorY: 0.5
    Common.HitBoxVisual.merge
      color: 0xffffff

    Common.Sound.merge
      soundId: 'short_beam'
      volume: 0.5
      playPosition: 0
      timeLimit: 500
      resound: true

    # Common.DeathTimer.merge
    #   time: BulletLifetime

  ]



module.exports = MissileLauncherSystem

