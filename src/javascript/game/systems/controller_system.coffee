class ControllerSystem
  run: (estore, dt, input) ->
    for controller in estore.getComponentsOfType('controller')
      if input.controllers and ins = input.controllers[controller.inputName]
        states = controller.states
        _.forOwn ins, (val,key) ->
          states[key] = val

module.exports = ControllerSystem
