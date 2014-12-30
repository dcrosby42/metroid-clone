class SamusMotionSystem
  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      controller = estore.getComponent(samus.eid, 'controller')
      movement = estore.getComponent(samus.eid, 'movement')

      position = estore.getComponent(samus.eid, 'position') # TODO something better!

      movement.x = 0

      runDist   = samus.runSpeed * dt
      jumpDist = samus.jumpSpeed * dt
      floatDist = samus.floatSpeed * dt

      ctrl = controller.states
      
      if ctrl.up
        samus.aim = 'up'
      else
        samus.aim = 'straight'

      if ctrl.left
        samus.direction = 'left'
      else if ctrl.right
        samus.direction = 'right'

      switch samus.action
        when 'standing'
          movement.y = 0
          if ctrl.right
            samus.action = 'running'
            movement.x = runDist
          else if ctrl.left
            samus.action = 'running'
            movement.x = -runDist
          
          if ctrl.jump
            samus.action = 'jumping'
            movement.y = -jumpDist

        when 'running'
          movement.y = 0
          if ctrl.right
            movement.x = runDist
          else if ctrl.left
            movement.x = -runDist

          if ctrl.jump
            samus.action = 'jumping'
            movement.y = -jumpDist
          
          if movement.x == 0
            samus.action = 'standing'

        when 'falling'
          movement.y = jumpDist
          ctrl.jump = false

          if position.y >= 206
            position.y = 206
            samus.action = 'standing'

          if ctrl.left
            movement.x = -floatDist
          else if ctrl.right
            movement.x = floatDist

        when 'jumping'

          if ctrl.jump
            movement.y = -jumpDist
          else
            samus.action = 'falling'

          if ctrl.left
            movement.x = -floatDist
          else if ctrl.right
            movement.x = floatDist

            
module.exports = SamusMotionSystem
