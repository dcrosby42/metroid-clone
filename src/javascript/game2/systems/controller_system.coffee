BaseSystem = require '../../ecs2/base_system'
PressedReleased = require '../../utils/pressed_released2'
C = require '../../components'
T = C.Types

class ControllerSystem extends BaseSystem
  @Subscribe: [ T.Controller ]

  process: (r) ->
    controller = r.comps[0]

    actionmap = @input.get('controllers').get(controller.inputName)
    actions = if actionmap?
      actionmap.toJS()
    else
      {}
    PressedReleased.update(controller.states, actions)
    for key,val of controller.states
      @publishEvent r.eid, key

module.exports = -> new ControllerSystem()

