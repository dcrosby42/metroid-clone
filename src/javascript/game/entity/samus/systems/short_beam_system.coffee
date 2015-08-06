Common = require '../../components'
Immutable = require 'immutable'
StateMachine = require '../../../../ecs/state_machine'


GUN_SETTINGS =
  offsetX: 10
  offsetY: -22
  muzzleVelocity: 200/1000
  bulletLife: 50 / (200/1000)

newBullet = (shortBeam, position,direction) ->
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
      damage: shortBeam.get('damage')
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




isShooting = (controller) -> controller.getIn(['states','action1'])

module.exports =
  config:
    filters: ['samus', 'short_beam','controller', 'position']

  fsm:
    property: 'short_beam.state'
    default: 'idle'
    states:

      idle:
        enter: (comps,input,u)->
          u.update comps.get('short_beam').set('cooldown',0)
        update: (comps,input,u) ->
          if isShooting(comps.get('controller'))
            'shoot'

      shoot:
        enter: (comps,input,u) ->
          u.newEntity newBullet(comps.get('short_beam'), comps.get('position'), comps.getIn(['samus','direction']))
          
        update: (comps,input,u) ->
          'cooldown'

      cooldown:
        enter: (comps,input,u) ->
          u.update comps.get('short_beam').set('cooldown',150)

        update: (comps,input,u) ->
          if isShooting(comps.get('controller'))
            shortBeam = comps.get('short_beam')
            t = shortBeam.get('cooldown') - input.get('dt')
            if t <= 0
              'shoot'
            else
              u.update shortBeam.set('cooldown', t)
              null
          else
            'idle'

