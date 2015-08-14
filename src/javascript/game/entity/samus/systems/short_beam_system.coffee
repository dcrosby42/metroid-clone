Common = require '../../components'
Immutable = require 'immutable'
StateMachineSystem = require '../../../../ecs/state_machine_system'

MuzzleVelocity = 200/1000
BulletLifetime = 50 / (200/1000)

newBullet = (weapon, position,direction,shootUp) ->
  offsetX = offsetY = vx = vy = 0

  if shootUp
    offsetX = 2.5
    offsetY = -35
    vx = 0
    vy = -MuzzleVelocity
    if direction == 'left'
      offsetX = -2
  else
    offsetX = 10
    offsetY = -22
    vx = MuzzleVelocity
    vy = 0
    if direction == 'left'
      offsetX = -offsetX
      vx = -vx

  fireX = position.get('x') + offsetX
  fireY = position.get('y') + offsetY

  return [
    Common.Bullet.merge
      damage: weapon.get('damage')
    Common.Visual.merge
      layer: 'creatures'
      spriteName: 'bullet'
      state: 'normal'

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
      volume: 0.2
      playPosition: 0
      timeLimit: 55
      resound: true

    Common.DeathTimer.merge
      time: BulletLifetime

  ]


class ShortBeamSystem extends StateMachineSystem
  @Subscribe: ['short_beam', 'samus', 'controller', 'position']

  @StateMachine:
    componentProperty: ['short_beam','state']
    start: 'ready'
    states:
      ready:
        events:
          triggerPulled:
            action:    'shoot'
            nextState: 'cooling'
          triggerHeld:
            action:    'repeat'
            nextState: 'cooling'
      cooling:
        events:
          cooldownComplete:
            nextState: 'ready'
          triggerReleased:
            action:    'reset'
            nextState: 'ready'

  shootAction: ->
    @_fireBullet()
    @_startCooldown(500)

  repeatAction: ->
    @_fireBullet()
    @_startCooldown(150)

  resetAction: ->
    # Clear cooldown timer(s):
    @getEntityComponents(@eid(), 'timer', 'name', 'shortBeamCooldown').forEach (comp) =>
      @deleteComp comp

  _fireBullet: ->
    dir = @getProp('samus','direction')
    shootUp = @getProp('samus','aim') == 'up'
    shortBeam = @getComp('short_beam')
    pos = @getComp('position')
    @newEntity newBullet(shortBeam,pos,dir,shootUp)

  _startCooldown: (ms) ->
    @addComp Common.Timer.merge
      time: ms
      event: 'cooldownComplete'
      name: 'shortBeamCooldown'


module.exports = ShortBeamSystem

