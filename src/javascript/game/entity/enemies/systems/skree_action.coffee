Common = require '../../components'
StateMachineSystem = require '../../../../ecs/state_machine_system'
AnchoredBox = require '../../../../utils/anchored_box'

class SkreeActionSystem extends StateMachineSystem
  @Subscribe: [
    ["skree", "position", "velocity", "hit_box", "visual"]
    ["samus", "position"]
  ]
  @ImplyEntity: 'skree'

  @StateMachine:
    componentProperty: ['skree', 'action']
    start: 'sleeping'
    states:
      sleeping:
        events:
          approached:
            action: 'launch'
            nextState: 'tracking'
      tracking:
        events:
          grounded:
            action: 'startCountdown'
            nextState: 'destructing'
      destructing:
        events:
          destructTimerComplete:
            action: 'detonate'

  sleepingState: ->
    dist = Math.abs(@getProp('skree-position','x') - @getProp('samus-position','x'))
    if dist <= @getProp('skree','triggerRange')
      @publishEvent 'approached'

  launchAction: ->
    @setProp 'skree-visual', 'state', 'spinFast'
    @setProp 'skree-visual', 'time', 0
    gravity = Common.Gravity.merge
      max: 300/1000
      accel: (200/1000)/10
    @addComp gravity
      
  trackingState: ->
    hitBox = @getComp('skree-hit_box')
    if hitBox.getIn(['touching','bottom'])
      @publishEvent 'grounded'
    else
      samusX = @getProp('samus-position','x')
      skreeX = @getProp('skree-position','x')
      speed = @getProp('skree', 'strafeSpeed')
      vx = if samusX < skreeX
        -speed
      else if samusX > skreeX
        speed
      else
        0
      @setProp 'skree-velocity', 'x', vx
      
  startCountdownAction: ->
    @setProp 'skree-velocity','x',0
    @setProp 'skree-velocity','y',0
    @setProp 'skree','countdown',1000

  destructingState: ->
    @updateProp 'skree','countdown', (t) => t - @dt()
    if @getProp('skree','countdown') <= 0
      @publishEvent 'destructTimerComplete'

  detonateAction: ->
    console.log "Skree #{@eid()} EXPLODES"

    @destroyEntity() # kill the Skree
    
    box = new AnchoredBox(@getComp('skree-hit_box').toJS())
    x = box.centerX
    y = box.centerY

    magnitude = 0.5
    rad = Math.PI / 3
    ax = magnitude * Math.cos(rad)
    ay = magnitude * Math.sin(rad)

    @_createShrapnel(x,y, magnitude, 0)
    @_createShrapnel(x,y, -magnitude, 0)
    @_createShrapnel(x,y, ax,-ay)
    @_createShrapnel(x,y, -ax,-ay)


  _createShrapnel: (x,y, vx,vy) ->
    
    @newEntity [
      Common.Visual.merge
        layer: 'creatures'
        spriteName: 'skree_shrapnel'
        state: 'normal'
      Common.MapGhost
      Common.Position.merge
        x: x
        y: y
      Common.Velocity.merge
        x: vx
        y: vy
      Common.Harmful.merge
        damage: 5
      Common.HitBox.merge
        width: 7
        height: 7
        anchorX: 0.54
        anchorY: 0.54
      Common.HitBoxVisual
      Common.DeathTimer.merge
        time: 100
    ]


module.exports = SkreeActionSystem
