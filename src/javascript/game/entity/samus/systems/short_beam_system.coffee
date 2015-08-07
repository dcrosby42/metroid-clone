Common = require '../../components'
Immutable = require 'immutable'
StateMachine = require '../../../../ecs/state_machine2'
BaseSystem = require '../../../../ecs/base_system'

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


GunFsm = Immutable.fromJS
  start: 'ready'
  states:
    ready:
      events:
        triggerPulled:
          action:    'shoot'
        triggerHeld:
          action:    'repeat'
    coolDown:
      events:
        triggerHeld:
          action: 'chill'
        triggerReleased:
          nextState: 'ready'

class ShortBeamSystem extends BaseSystem
  constructor: ->
    super()

  process: ->
    events = @_getEvents() #XXX

    # Push events through the FSM for the short_beam
    s = @get('short_beam').get('state')
    s1 = StateMachine.processEvents(GunFsm, s, events, @)
    unless s1 == s
      @update @get('short_beam').set('state', s1)

  shoot: ->
    @_fireBullet()
    return @_cooldown(500)

  repeat: ->
    @_fireBullet()
    return @_cooldown(150)

  chill: ->
    remain = @getProp('short_beam', 'cooldown') - @dt()
    if remain > 0
      @_cooldown(remain)
      return null
    else
      @_cooldown(0)
      return 'ready'

  _cooldown: (ms) ->
    @update @get('short_beam').set('cooldown',ms)
    'coolDown'

  _fireBullet: ->
    dir = @get('samus').get('direction')
    shortBeam = @get('short_beam')
    pos = @get('position')
    @newEntity newBullet(shortBeam,pos,dir)


  _getEvents: ->
    # XXX: Don't generate events here, generate them somewhere else
    events = Immutable.List()
    if @get('controller').getIn(['states','action1Pressed'])
      events = events.push('triggerPulled')
    else if @get('controller').getIn(['states','action1'])
      events = events.push('triggerHeld')
    else if @get('controller').getIn(['states','action1Released'])
      events = events.push('triggerReleased')
    events = events.push('time')
    return events

shortBeamSystem = new ShortBeamSystem()

module.exports =
  config:
    filters: ['samus', 'short_beam','controller', 'position']

  update: (comps,input,u) ->
    shortBeamSystem.handleUpdate(comps, input, u)
