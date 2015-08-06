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

  actions:
    shoot: ->
      dir = @get('samus').get('direction')
      shortBeam = @get('short_beam')
      pos = @get('position')
      @newEntity newBullet(shortBeam,pos,dir)
      @update shortBeam.set('cooldown',500)
      'coolDown'

    repeat: ->
      dir = @get('samus').get('direction')
      shortBeam = @get('short_beam')
      pos = @get('position')
      @newEntity newBullet(shortBeam,pos,dir)
      @update shortBeam.set('cooldown',150)
      'coolDown'

    chill: ->
      shortBeam = @get('short_beam')
      remain = shortBeam.get('cooldown') - @dt()
      if remain > 0
        @update shortBeam.set('cooldown', remain)
        return null
      else
        @update shortBeam.set('cooldown', 0)
        return 'ready'

DefaultHandlerDef = Immutable.Map(action: null)

nextState = (fsm, state, event, obj) ->
  state ||= fsm.get('start')
  s1 = null
  handlerDef = fsm.getIn(['states',state,'events',event]) || DefaultHandlerDef
  if actionName = handlerDef.get('action')
    if action = fsm.getIn(['actions',actionName])
      s1 = action.apply(obj)
  return (s1 || handlerDef.get('nextState') || state)

processEvents = (fsm, state, events, obj) ->
  s = state
  events.forEach (e) ->
    s = nextState(fsm, s, e, obj)
  s
    
class BaseSystem
  constructor: ->
    @reset()

  setup: (@comps,@input,@updater) ->

  process: ->
    
  reset: ->
    @comps = null
    @input = null
    @updater = null
    @cache = {}
    @nameCache = {}
    @updatedComps = {}
    @updatedCompNames = []

  handleUpdate: (comps, input, u) ->
    @setup(comps,input,u)
    @process()
    @sync()
    @reset()

  dt: ->
    @input.get('dt')

  get: (compName) ->
    comp = @cache[compName]
    if !comp?
      comp = @comps.get(compName)
      @cache[compName] = comp
      @nameCache[comp.get('cid')] = compName
    comp

  update: (comp) ->
    compName = @nameCache[comp.get('cid')]
    @cache[compName] = comp
    @updatedComps[compName] = comp
    @updatedCompNames.push compName

  newEntity: (comps) ->
    @updater.newEntity comps

  sync: ->
    for name in @updatedCompNames
      @updater.update @updatedComps[name]


class ShortBeamSystem extends BaseSystem
  constructor: ->
    super()

  process: ->
    #################################################################
    # XXX: Don't generate events here, generate them somewhere else
    events = Immutable.List()
    if @get('controller').getIn(['states','action1Pressed'])
      events = events.push('triggerPulled')
    else if @get('controller').getIn(['states','action1'])
      events = events.push('triggerHeld')
    else if @get('controller').getIn(['states','action1Released'])
      events = events.push('triggerReleased')
    events = events.push('time')
    #################################################################

    # Push events through the FSM for the short_beam
    # shortBeam = comps.get('short_beam')
    s = @get('short_beam').get('state')
    s1 = processEvents(GunFsm, s, events, @)
    unless s1 == s
      @update @get('short_beam').set('state', s1)

shortBeamSystem = new ShortBeamSystem()

module.exports =
  config:
    filters: ['samus', 'short_beam','controller', 'position']

  update: (comps,input,u) ->
    shortBeamSystem.handleUpdate(comps, input, u)
