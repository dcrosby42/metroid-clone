Common = require '../../components'
Immutable = require 'immutable'
StateMachineSystem = require '../../../../ecs/state_machine_system'

MuzzleVelocity = 200/1000
BulletLifetime = 50 / (200/1000)

class ShortBeamSystem extends StateMachineSystem
  @Subscribe: ['short_beam', 'samus', 'position']

  @StateMachine:
    componentProperty: ['short_beam','state']
    start: 'ready'
    states:
      ready:
        events:
          fireBeam:
            action:    'shoot'
            nextState: 'coolDown'
      coolDown:
        events:
          fireBeamReleased:
            action:    'reset'
            nextState: 'ready'
          cooldownComplete:
            nextState: 'repeating'
      repeating:
        events:
          keepFiring:
            action: 'repeat'
            nextState: 'coolDown'
          fireBeamReleased:
            action: 'reset'
            nextState: 'ready'

  shootAction: ->
    @_fireBullet()
    @_startCooldown(500)

  repeatingState: ->
    @publishEvent 'keepFiring'

  repeatAction: ->
    @_fireBullet()
    @_startCooldown(150)

  resetAction: ->
    # Clear cooldown timer(s):
    @getEntityComponents(@eid(), 'timer', 'name', 'shortBeamCooldown').forEach (comp) =>
      @deleteComp comp

  repeatState: ->
    @publishEvent 'done'
  

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
    Common.Name.merge(name: 'bullet')
    Common.Bullet.merge
      damage: weapon.get('damage')
    Common.Animation.merge
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
      volume: 0.5
      playPosition: 0
      timeLimit: 500
      resound: true

    Common.DeathTimer.merge
      time: BulletLifetime

  ]



module.exports = ShortBeamSystem

