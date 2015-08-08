Common = require '../../components'
StateMachineSystem = require '../../../../ecs/state_machine_system'

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
    @destroyEntity @eid()

module.exports = SkreeActionSystem
