Immutable = require 'immutable'

exports.create = (control,action) ->
  Immutable.Map
    type: 'ControllerEvent'
    control: control
    action: action
