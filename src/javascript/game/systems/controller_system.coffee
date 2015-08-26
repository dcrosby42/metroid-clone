PressedReleased = require '../../utils/pressed_released'
BaseSystem = require '../../ecs/base_system'

class ControllerSystem extends BaseSystem
  @Subscribe: [ 'controller' ]

  process: ->
    ins = @input.getIn(['controllers', @getProp('controller', 'inputName')])
    states = @updateProp('controller', 'states', (s) -> PressedReleased.update(s, ins))
    
    @_generateControllerEvents(states)

  _generateControllerEvents: (states) ->

    if states.get('action1Pressed')
      @publishEvent 'triggerPulled'
    else if states.get('action1')
      @publishEvent 'triggerHeld'
    else if states.get('action1Released')
      @publishEvent 'triggerReleased'

    for s in ['up','down','left','right','action1','action2','start']
      if states.get("#{s}Pressed")
        @publishEvent "#{s}Pressed"
      else if states.get(s)
        @publishEvent "#{s}Held"
      else if states.get("#{s}Released")
        @publishEvent "#{s}Released"





module.exports = ControllerSystem

