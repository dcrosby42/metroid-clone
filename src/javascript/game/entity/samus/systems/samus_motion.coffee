BaseSystem = require '../../../../ecs/base_system'

class SamusMotionSystem extends BaseSystem
  @Subscribe: ['samus', 'velocity', 'hit_box']

  process: ->
    velocity = @getComp('velocity')
    hitBox = @getComp('hit_box')
    @updateProp 'samus', 'motion', (m) =>
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
      

module.exports = SamusMotionSystem

