Common = require '../../components'
StateMachineSystem = require '../../../../ecs/state_machine_system'

class SkreeActionSystem extends StateMachineSystem
  @Subscribe: [
    ["skree", "position", "velocity", "hit_box"]
    ["samus", "position"]
  ]

  @StateMachine:
    componentProperty: ['skree', 'action']
    start: 'sleep'
    states:
      sleep:
        events:
          time:
            action: 'sleep'
      attack:
        events:
          time:
            action: 'attack'
      countdown:
        events:
          time:
            action: 'countdown'

  sleep: ->
    dist = Math.abs(@getProp('skree-position','x') - @getProp('samus-position','x'))
    if dist <= @getProp('skree','triggerRange')
      gravity = Common.Gravity.merge
        max: 300/1000
        accel: (200/1000)/10
      @addComponent @getProp('skree','eid'), gravity
      return 'attack'
    else
      return 'sleep'
      
  attack: ->
    hitBox = @get('skree-hit_box')
    velocity = @get('skree-velocity')
    if hitBox.getIn(['touching','bottom'])
      @update velocity.set('x',0).set('y',0)
      @setProp 'skree','countdown',1000
      return 'countdown'

    else
      samusX = @getProp('samus-position','x')
      skreeX = @getProp('skree-position','x')
      speed = @getProp('skree', 'strafeSpeed')
      
      dir = vx = null
      if samusX < skreeX
        dir = 'left'
        vx = -speed
      else if samusX > skreeX
        dir = 'right'
        vx = speed
      else
        dir = 'neither'
        vx = 0

      # TODO: Remove or use dir!!
      if vx != velocity.get('x')
        @update velocity.set('x', vx)

    null # no state change

  countdown: ->
    @updateProp 'skree','countdown', (t) => t - @dt()
    if @getProp('skree','countdown') <= 0
      # u.update skree.set('action', 'explode').set('countdown',t)
      eid = @getProp('skree', 'eid')
      console.log "Skree #{eid} EXPLODES"
      @destroyEntity eid
        
    null

module.exports = SkreeActionSystem
