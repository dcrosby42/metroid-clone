module.exports =
  config:
    filters: ['samus', 'velocity', 'hit_box']

  update: (comps, input, u) ->
    comps.get('velocity')
    comps.get('hit_box')
    comps.get('samus').update 'motion', (m) ->
      if velocity.get('y') < 0
        'jumping'
      else if velocity.get('y') > 0
        'falling'
      else if hitBox.getIn(['touching','bottom'])
        if velocity.get('x') == 0
          'standing'
        else
          'running'
      else if hitBox.getIn(['touching','top'])
        'falling'
      
