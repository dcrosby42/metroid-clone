Common = require './../../components'

module.exports =
  config:
    filters: [
      ["skree", "position", "velocity"]
      ["samus", "position"]
    ]

  state_machine:
    property:  'skree.action'
    states:
      sleep:
        samus_near: 'attack'
      attack:
        hit_ground: 'countdown'
      countdown:
        timeout: 'explode'
      explode: {}

    handlers:
      sleep:
        update: (comps,input,u,e) ->
          samus = comps.get('samus')
          skreePosition = comps.get('skree-position')
          samusPosition = comps.get('samus-position')
          dist = Math.abs(skreePosition.get('x') - samusPosition.get('x'))
          if dist <= skree.get('triggerRange')
            e 'samus_near'

      attack:
        enter: (comps,input,u,e) ->
          eid = comps.getIn(['skree','eid'])
          u.add eid, Common.Gravity.merge
            max: 300/1000
            accel: (200/1000)/10

        update: (comps,input,u,e) ->
          skree = comps.get('skree')
          hitBox = u.getEntityComponent skree.get('eid'), 'hit_box'
          if hitBox.getIn(['touching','bottom'])
            e 'hit_ground'
          else
            samusPosition = comps.get('samus-position')
            skreePosition = comps.get('skree-position')
            speed = skree.get('strafeSpeed')
            dt = input.get('dt')
            
            dir = if samusPosition.get('x') < skreePosition.get('x')
              'left'
            else if samusPosition.get('x') > skreePosition.get('x')
              'right'
            else
              'neither'

            vx = if samusPosition.get('x') < skreePosition.get('x')
              -speed
            else if samusPosition.get('x') > skreePosition.get('x')
              speed
            else
              0

      countdown:
        enter: (comps,input,u,e) ->
          skree = comps.get('skree')
          velocity = comps.get('skree-velocity')
          u.update skree.set('direction', 'neither').set('countdown', 1000)
          u.update velocity.set('x',0).set('y',0)

        update: (comps,input,u,e) ->
          skree = comps.get('skree')
          t = skree.get('countdown')
          t -= input.get('dt')
          if t <= 0
            e 'timeout'
          else
            u.update skree.set('countdown',t)

      explode:
        enter: (comps,input,u,e) ->
          skree = comps.get('skree')
          u.destroyEntity skree.get('eid')



  update: (comps,input,u) ->
    skree = comps.get('skree')
    skreeEid = skree.get('eid')

    action = skree.get('action')
    switch action
      when 'sleep'
        samus = comps.get('samus')
        skreePosition = comps.get('skree-position')
        samusPosition = comps.get('samus-position')
        samusDistance = Math.abs(skreePosition.get('x') - samusPosition.get('x'))
        if samusDistance <= skree.get('triggerRange')
          # Update Skree state to attack samus:
          u.update skree.set('action', 'attack')

          # Cause Skree to accelerate toward floor:
          gravity = Common.Gravity.merge
            max: 300/1000
            accel: (200/1000)/10
          u.add skreeEid, gravity

      when 'attack'
        hitBox = u.getEntityComponent skree.get('eid'), 'hit_box'
        velocity = comps.get('skree-velocity')
        if hitBox.getIn(['touching','bottom'])
          u.update skree.set('action', 'countdown').set('direction', 'neither').set('countdown', 1000)
          u.update velocity.set('x',0).set('y',0)
        else
          samusPosition = comps.get('samus-position')
          skreePosition = comps.get('skree-position')
          speed = skree.get('strafeSpeed')
          dt = input.get('dt')
          
          dir = if samusPosition.get('x') < skreePosition.get('x')
            'left'
          else if samusPosition.get('x') > skreePosition.get('x')
            'right'
          else
            'neither'

          vx = if samusPosition.get('x') < skreePosition.get('x')
            -speed
          else if samusPosition.get('x') > skreePosition.get('x')
            speed
          else
            0

          # if dir != skree.get('direction')
          #   u.update skree.set('direction', dir)
          if vx != velocity.get('x')
            u.update velocity.set('x', vx)

      when 'countdown'
        t = skree.get('countdown')
        t -= input.get('dt')
        if t <= 0
          u.update skree.set('action', 'explode').set('countdown',t)
        else
          u.update skree.set('countdown',t)
        
      when 'explode'
        0
        # console.log "Skree #{skreeEid} EXPLODES"
        # u.destroyEntity skreeEid
