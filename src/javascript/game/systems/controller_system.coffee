PressedReleased = require '../../utils/pressed_released'
BaseSystem = require '../../ecs/base_system'

class ControllerSystem extends BaseSystem
  @Subscribe: [ 'controller' ]

  process: ->
    ins = @input.getIn(['controllers', @getProp('controller', 'inputName')])
    states = @updateProp('controller', 'states', (s) -> PressedReleased.update(s, ins))
    states.forEach (val,key) =>
      # false vals would already be filtered out by PressedRelease.update
      @publishEvent key


module.exports = ControllerSystem

