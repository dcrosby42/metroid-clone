BaseSystem = require '../../ecs2/base_system'
PressedReleased = require '../../utils/pressed_released2'
C = require '../../components'
T = C.Types

class ControllerSystem extends BaseSystem
  @Subscribe: [ T.Controller ]

  process: (r) ->
    controller = r.comps[0]

    # ins = @input.getIn(['controllers', @getProp('controller', 'inputName')])
    ins = @input.get('controllers').get(controller.inputName)
    ins = ins.toJS()

    PressedReleased.update(controller.states, ins)
    for key,val of controller.states
      @publishEvent key

module.exports = -> new ControllerSystem()

