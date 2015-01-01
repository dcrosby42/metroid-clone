
class SamusControllerAction
  run: (estore,dt,input) ->
    for samus in estore.getComponentsOfType('samus')
      controller = estore.getComponent(samus.eid, 'controller')
      ctrl = controller.states
      
      if ctrl.up
        samus.aim = 'up'
      else
        samus.aim = 'straight'
    
      if ctrl.left
        samus.direction = 'left'
      else if ctrl.right
        samus.direction = 'right'

      switch samus.motion
        when 'standing'
          if ctrl.jump
            samus.action = 'jump'
          else if ctrl.right or ctrl.left
            samus.action = 'run'

        when 'running'
          if ctrl.jump
            samus.action = 'jump'
          else if ctrl.right or ctrl.left
            # If we don't re-iterate the run action, mid-run direction changes will not register
            samus.action = 'run'
          else
            samus.action = 'stand'

        when 'falling'
          if ctrl.left or ctrl.right
            samus.action = 'drift'

        when 'jumping'
          if !ctrl.jump
            samus.action = 'fall'

          if ctrl.left or ctrl.right
            samus.action = 'drift'

      # if samus.action?
      #   console.log "action: #{samus.action}"

module.exports = SamusControllerAction

