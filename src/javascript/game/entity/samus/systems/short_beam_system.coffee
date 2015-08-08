Common = require '../../components'
Immutable = require 'immutable'
StateMachineSystem = require '../../../../ecs/state_machine_system'

GUN_SETTINGS =
  offsetX: 10
  offsetY: -22
  muzzleVelocity: 200/1000
  bulletLife: 50 / (200/1000)

newBullet = (weapon, position,direction) ->
  offsetX = GUN_SETTINGS.offsetX
  offsetY = GUN_SETTINGS.offsetY
  velocity = GUN_SETTINGS.muzzleVelocity

  if direction == 'left'
    offsetX = -offsetX
    velocity = -velocity

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
      x: velocity
      y: 0
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
      time: GUN_SETTINGS.bulletLife

  ]


class ShortBeamSystem extends StateMachineSystem
  @Subscribe: ['samus', 'short_beam','controller', 'position']

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
    @getEntityComponents(@getProp('short_beam','eid'), 'timer').forEach (comp) =>
      if comp.get('name') == 'shortBeamCooldown'
        @delete comp

  _fireBullet: ->
    dir = @getProp('samus','direction')
    shortBeam = @get('short_beam')
    pos = @get('position')
    @newEntity newBullet(shortBeam,pos,dir)

  _startCooldown: (ms) ->
    eid = @getProp('short_beam','eid')
    @addComponent eid, Common.Timer.merge
      time: ms
      event: 'cooldownComplete'
      name: 'shortBeamCooldown'


module.exports = ShortBeamSystem

