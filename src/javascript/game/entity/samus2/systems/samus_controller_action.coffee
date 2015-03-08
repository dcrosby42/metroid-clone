
class SamusControllerAction
  run: (estore,dt,input) ->
    # input: samus[motion] + controller[states]
    # output: samus[action]
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

      samus.action = null

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
            samus.action = 'stop'

        when 'falling'
          ctrl.jump = false
          if ctrl.left or ctrl.right
            samus.action = 'drift'
          else
            samus.action = 'stop'
            

        when 'jumping'
          if !ctrl.jump
            samus.action = 'fall'

          else if ctrl.left or ctrl.right
            samus.action = 'drift'

      if ctrl.shoot
        if samus.weaponTrigger == 'released'
          samus.weaponTrigger = 'pulled'
        else
          samus.weaponTrigger = 'held'
      else
        samus.weaponTrigger = 'released'
      
      # if samus.action?
      #   console.log "action: #{samus.action}"

module.exports = SamusControllerAction

