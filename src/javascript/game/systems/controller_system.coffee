PressedReleased = require '../../utils/pressed_released'

module.exports =
  config:
    filters: [ 'controller' ]

  update: (comps, input, u) ->
    controller = comps.get('controller')
    ins = input.getIn(['controllers', controller.get('inputName')])
    u.update controller.update 'states', (s) -> PressedReleased.update(s, ins)


