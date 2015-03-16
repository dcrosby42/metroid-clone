
module.exports =
  config:
    filters: ['samus','controller']

  update: (comps,input,u) ->
    samus = comps.get('samus')
    ctrl = comps.getIn(['controller','states'])


    aim = if ctrl.get('up') then 'up' else 'straight'
      
    direction = if ctrl.get('left')
      'left'
    else if ctrl.get('right')
      'right'
    else
      samus.get('direction')
      
    sideways = ctrl.get('right') or ctrl.get('left')

    action = switch samus.get('motion')
      when 'standing'
        if ctrl.get('jump')
          'jump'
        else if sideways
          'run'

      when 'running'
        if ctrl.get('jump')
          'jump'
        else if sideways
          # If we don't re-iterate the run action, mid-run direction changes will not register
          'run'
        else
          'stop'

      when 'falling'
        if sideways
          'drift'
        else
          'stop'
          
      when 'jumping'
        if !ctrl.get('jump')
          'fall'

        else if sideways
          'drift'

    weaponTrigger = if ctrl.get('shoot')
      if samus.get('weaponTrigger') == 'released'
        'pulled'
      else
        'held'
    else
      'released'

    u.update(samus
      .set('aim', aim)
      .set('direction', direction)
      .set('action', action)
      .set('weaponTrigger', weaponTrigger))

     # TODO is this really necessary? Because this is kinda jank, updating the controller states like this...
    if samus.get('motion') == 'falling'
      u.update(comps.get('controller').setIn(['states','jump'], false))
    
