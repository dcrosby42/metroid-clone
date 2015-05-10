Common = require '../../components'
Immutable = require 'immutable'
StateMachine = require '../../../../ecs/state_machine'

isShooting = (controller) -> controller.getIn(['states','action1'])

GUN_SETTINGS =
  offsetX: 10
  offsetY: -22
  muzzleVelocity: 200/1000
  bulletLife: 50 / (200/1000)

newBullet = (position,direction) ->
  offsetX = GUN_SETTINGS.offsetX
  offsetY = GUN_SETTINGS.offsetY
  velocity = GUN_SETTINGS.muzzleVelocity

  if direction == 'left'
    offsetX = -offsetX
    velocity = -velocity

  fireX = position.get('x') + offsetX
  fireY = position.get('y') + offsetY

  return [
    Common.Bullet
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






system =
  config:
    filters: ['samus', 'short_beam','controller', 'position']

  fsm:
    property: 'short_beam.state'
    states:
      idle:
        name: 'idle'
        update: (comps,input,u) ->
          if isShooting(comps.get('controller'))
            'shoot'

      shoot:
        name: 'shoot'
        enter: (comps,input,u) ->
          u.newEntity newBullet(comps.get('position'), comps.getIn(['samus','direction']))
          null
        update: (comps,input,u) ->

          if !isShooting(comps.get('controller'))
            'idle'

  # update: (comps,input,u) ->
  #   doFsmThing 'short_beam.state', states, comps, input, u

transformFsmSystem = (system) ->
  system = Immutable.fromJS(system)
  fsm = system.get('fsm')
  if fsm?
    property = fsm.get('property')
    states = fsm.get('states')
    system.set('update', (comps,input,u) -> StateMachine.update(property, states, comps, input, u))
  else
    system

module.exports = transformFsmSystem(system)

