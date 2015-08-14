BaseSystem = require '../../../../ecs/base_system'

class SamusControllerActionSystem extends BaseSystem
  @Subscribe: ['samus','controller']

  process: ->
    samus = @getComp('samus')
    ctrl = @getProp 'controller', 'states'

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


    @updateComp(samus
      .set('aim', aim)
      .set('direction', direction)
      .set('action', action)
    )

module.exports = SamusControllerActionSystem

