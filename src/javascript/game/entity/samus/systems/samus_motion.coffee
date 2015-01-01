class SamusMotion
  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      velocity = estore.getComponent(samus.eid, 'velocity')
      hitBox = estore.getComponent(samus.eid, 'hit_box')

      m = samus.motion
      samus.motion = if velocity.y < 0
        'jumping'
      else if velocity.y > 0
        'falling'
      else if hitBox.touching.bottom
        if velocity.x == 0
          'standing'
        else
          'running'
      else if hitBox.touching.top
        'falling'

      # if samus.motion != m
        # console.log "Motion updated: #{samus.motion}"
    
module.exports = SamusMotion
