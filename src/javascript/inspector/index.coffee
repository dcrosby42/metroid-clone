
module.exports =
  createComponentInspector: (el) ->
    # PreComponentInspector = require './pre_component_inspector'
    # new PreComponentInspector(el)
    ReactComponentInspector = require './react_component_inspector'
    new ReactComponentInspector(el)

