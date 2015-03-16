module.exports =
  config:
    filters: [ 'controller' ]

  update: (comps, input, u) ->
    controller = comps.get('controller')
    u.update controller.set 'states', input.getIn(['controllers', controller.get('inputName')])


