module.exports =
  config:
    filters: [ 'controller' ]

  update: (comps, input, u) ->
    controller = comps.get('controller')
    if ins = input.getIn(['controllers', controller.get('inputName')])
      u.update controller.set 'states', ins


