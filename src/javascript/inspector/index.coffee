ReactComponentInspector = require './react_component_inspector'

module.exports =
  createComponentInspector: (args...) ->
    new ReactComponentInspector(args...)

