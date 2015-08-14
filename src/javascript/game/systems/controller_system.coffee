PressedReleased = require '../../utils/pressed_released'
BaseSystem = require '../../ecs/base_system'

class ControllerSystem extends BaseSystem
  @Subscribe: [ 'controller' ]

  process: ->
    ins = @input.getIn(['controllers', @getProp('controller', 'inputName')])
    states = @updateProp('controller', 'states', (s) -> PressedReleased.update(s, ins))
    
    if states.get('action1Pressed')
      @publishEvent 'triggerPulled'
    else if states.get('action1')
      @publishEvent 'triggerHeld'
    else if states.get('action1Released')
      @publishEvent 'triggerReleased'



module.exports = ControllerSystem

