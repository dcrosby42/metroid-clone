
module.exports =
  config:
    filters: ['short_beam','controller']

  update: (comps,input,u) ->
    shortBeam = comps.get('short_beam')
    controller = comps.get('controller')
    
    state = if controller.getIn(['states', 'action1'])
      if shortBeam.get('state') == 'released'
        'pulled'
      else
        'held'
    else
      'released'

    u.update(shortBeam
      .set('state', state))
