class SamusMotion
  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      velocity = estore.getComponent(samus.eid, 'velocity')

      m = samus.motion
      samus.motion = if velocity.y < 0
        'jumping'
      else if velocity.y > 0
        'falling'
      else
        if velocity.x == 0
          'standing'
        else
          'running'

      # if samus.motion != m
        # console.log "Motion updated: #{samus.motion}"
    
module.exports = SamusMotion
