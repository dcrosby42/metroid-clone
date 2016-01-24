BaseSystem = require '../../../../ecs/base_system'

class SamusControllerActionSystem extends BaseSystem
  @Subscribe: ['samus','controller']

  process: ->
    samus = @getComp('samus')
    ctrl = @getProp 'controller', 'states'
    
    # Direction
    sideways = false
    if ctrl.get('left')
      @setProp 'samus', 'direction', 'left'
      sideways = true
    else if ctrl.get('right')
      @setProp 'samus', 'direction', 'right'
      sideways = true

    # Aim
    if ctrl.get('up')
      @setProp 'samus', 'aim', 'up'
    else if ctrl.get('upReleased')
      @setProp 'samus', 'aim', 'straight'
      
    @setProp 'samus','action',switch samus.get('motion')
      when 'standing'
        if ctrl.get('action2Pressed')
          'jump'
        else if sideways
          'run'
        else
          'stop'

      when 'running'
        if ctrl.get('action2Pressed')
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
        if !ctrl.get('action2')
          'fall'

        else if sideways
          'drift'

module.exports = SamusControllerActionSystem

