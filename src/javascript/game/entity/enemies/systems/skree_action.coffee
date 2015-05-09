Common = require './../../components'

module.exports =
  config:
    # filters: ['skree','position']
    # filters: [
    #   { match: { type: 'skree' }, as: 'skree' }
    #   { match: { type: 'position' }, as: 'skreePosition', join: "skree.eid" }
    #
    #   { match: { type: 'samus' }, as: 'samus' }
    #   { match: { type: 'position' }, as: 'samusPosition', join: "samues.eid" }
    # ]
    filters: [
      ["skree", "position", "velocity"]
      ["samus", "position"]
    ]

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
