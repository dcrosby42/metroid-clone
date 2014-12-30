class SystemsRunner
  constructor: (@systems) ->
  run: (estore, dt, input) ->
    for system in @systems
      system.run estore, dt, input

module.exports = SystemsRunner
