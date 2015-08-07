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


  # update: (comps,input,u) ->
  #   skree = comps.get('skree')
  #   skreeEid = skree.get('eid')
  #
  #   action = skree.get('action')
  #   switch action
  #     when 'sleep'
  #       samus = comps.get('samus')
  #       skreePosition = comps.get('skree-position')
  #       samusPosition = comps.get('samus-position')
  #       samusDistance = Math.abs(skreePosition.get('x') - samusPosition.get('x'))
  #       if samusDistance <= skree.get('triggerRange')
  #         # Update Skree state to attack samus:
  #         u.update skree.set('action', 'attack')
  #
  #         # Cause Skree to accelerate toward floor:
  #         gravity = Common.Gravity.merge
  #           max: 300/1000
  #           accel: (200/1000)/10
  #         u.add skreeEid, gravity
  #
  #     when 'attack'
  #       hitBox = u.getEntityComponent skree.get('eid'), 'hit_box'
  #       velocity = comps.get('skree-velocity')
  #       if hitBox.getIn(['touching','bottom'])
  #         u.update skree.set('action', 'countdown').set('direction', 'neither').set('countdown', 1000)
  #         u.update velocity.set('x',0).set('y',0)
  #       else
  #         samusPosition = comps.get('samus-position')
  #         skreePosition = comps.get('skree-position')
  #         speed = skree.get('strafeSpeed')
  #         dt = input.get('dt')
  #         
  #         dir = if samusPosition.get('x') < skreePosition.get('x')
  #           'left'
  #         else if samusPosition.get('x') > skreePosition.get('x')
  #           'right'
  #         else
  #           'neither'
  #
  #         vx = if samusPosition.get('x') < skreePosition.get('x')
  #           -speed
  #         else if samusPosition.get('x') > skreePosition.get('x')
  #           speed
  #         else
  #           0
  #
  #         # if dir != skree.get('direction')
  #         #   u.update skree.set('direction', dir)
  #         if vx != velocity.get('x')
  #           u.update velocity.set('x', vx)
  #
  #     when 'countdown'
  #       t = skree.get('countdown')
  #       t -= input.get('dt')
  #       if t <= 0
  #         u.update skree.set('action', 'explode').set('countdown',t)
  #       else
  #         u.update skree.set('countdown',t)
  #       
  #     when 'explode'
  #       console.log "Skree #{skreeEid} EXPLODES"
  #       u.destroyEntity skreeEid
