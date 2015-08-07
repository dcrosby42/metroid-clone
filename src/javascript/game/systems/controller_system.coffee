PressedReleased = require '../../utils/pressed_released'

module.exports =
  config:
    filters: [ 'controller' ]

  update: (comps, input, u, eventBucket) ->
    controller = comps.get('controller')
    ins = input.getIn(['controllers', controller.get('inputName')])
    controller = controller.update 'states', (s) -> PressedReleased.update(s, ins)
    u.update controller

    eid = controller.get('eid')
    if controller.getIn(['states','action1Pressed'])
      eventBucket.addEventForEntity(eid, 'triggerPulled')
    else if controller.getIn(['states','action1'])
      eventBucket.addEventForEntity(eid, 'triggerHeld')
    else if controller.getIn(['states','action1Released'])
      eventBucket.addEventForEntity(eid, 'triggerReleased')




