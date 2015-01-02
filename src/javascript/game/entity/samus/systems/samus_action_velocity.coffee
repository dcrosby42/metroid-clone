
class SamusActionVelocity
  run: (estore,dt,input) ->
    # run | drift | stand | jump | fall
    for samus in estore.getComponentsOfType('samus')
      velocity = estore.getComponent(samus.eid, 'velocity')

      switch samus.action
        when 'run'
          if samus.direction == 'right'
            velocity.x = samus.runSpeed
          else
            velocity.x = -samus.runSpeed

        when 'drift'
          if samus.direction == 'right'
            velocity.x = samus.floatSpeed
          else
            velocity.x = -samus.floatSpeed

        when 'stop'
          velocity.x = 0

        when 'jump'
          velocity.y = -samus.jumpSpeed

        when 'fall'
          velocity.y = 0

      samus.action = null

      # TODO: Gravity system?
      # TODO: always apply? or just when airborn?
      max = 200/1000
      velocity.y += max/10
      velocity.y = max if velocity.y > max

module.exports = SamusActionVelocity

