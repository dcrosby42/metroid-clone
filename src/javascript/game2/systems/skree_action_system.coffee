StateMachineSystem = require '../../ecs2/state_machine_system'
Prefab = require '../prefab'
C = require '../../components'
T = C.Types
AnchoredBox = require '../../utils/anchored_box'

SkreeTriggerRange = 32
SkreeStrafeSpeed = 50/1000

class SkreeActionSystem extends StateMachineSystem
  @Subscribe: [
    [T.Skree, T.Position, T.Velocity, T.HitBox, T.Animation]
    [{type:T.Tag, name:'samus'}, T.Position]
  ]

  @StateMachine:
    componentProperty: [0, 'state']
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
    @_setComps()
    # [ [skree,skreePos], [samus,samusPos] ] = @rList

    dist = Math.abs(@skreePos.x - @samusPos.x)
    if dist <= SkreeTriggerRange
      @publishEvent @eid, 'approached'

  launchAction: ->
    @_setComps()
    # [ [skree,skreePos,vel,hitBox,animation] ] = @rList
    @animation.state = 'spinFast'
    @animation.time = 0
    @entity.addComponent C.buildCompForType T.Gravity, {
      max: 300/1000
      accel: (200/1000)/10
    }
      
  trackingState: ->
    @_setComps()
    # [ [skree,skreePos,skreeVel,hitBox,animation],[samus,samusPos] ] = @rList
    # hitBox = @getComp('skree-hit_box')
    if @hitBox.touching.bottom
      @publishEvent @eid, 'grounded'
    else
      vx = if @samusPos.x < @skreePos.x
        -SkreeStrafeSpeed
      else if @samusPos.x > @skreePos.x
        SkreeStrafeSpeed
      else
        0
      @skreeVel.x = vx
      
  startCountdownAction: ->
    @_setComps()
    # [ [skree,skreePos,skreeVel,hitBox,animation],[samus,samusPos] ] = @rList
    @skreeVel.x = 0
    @skreeVel.y = 0
    @entity.addComponent Prefab.timerComponent {
      time: 1000, eventName: 'destructTimerComplete'
    }

  # destructingState: ->
  #   @updateProp 'skree','countdown', (t) => t - @dt()
  #   if @getProp('skree','countdown') <= 0
  #     @publishEvent 'destructTimerComplete'

  detonateAction: ->
    @_setComps()
    # [ [skree,skreePos,skreeVel,hitBox,animation],[samus,samusPos] ] = @rList
    
    box = new AnchoredBox(@hitBox)
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

    @entity.destroy()

  _setComps: ->
    [@skree,@skreePos,@skreeVel,@hitBox,@animation] = @rList[0].comps
    [@samus,@samusPos] = @rList[1].comps

  _createShrapnel: (x,y, vx,vy) ->
    @estore.createEntity Prefab.enemy 'skreeShrapnel',
      position:
        x: x
        y: y
      velocity:
        x: vx
        y: vy
    


module.exports = -> new SkreeActionSystem()
