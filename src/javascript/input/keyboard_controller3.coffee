MousetrapWrapper = require '../vendor/mousetrap_wrapper'
Immutable = require 'immutable'

bindUpDown = (addEvent, type, key,control) ->
  MousetrapWrapper.bind key, (-> addEvent event(type, control, 'down')), 'keydown'
  MousetrapWrapper.bind key, (-> addEvent event(type, control, 'up')), 'keyup'

event = (type, control,action) ->
  Immutable.Map
    type:'ControllerEvent'
    control: control
    action: action

class KeyboardController
  constructor: (@address, @keyControls) ->
    @_actions = []
    for key,control of @keyControls
      bindUpDown @_addEvent.bind(@), 'ControllerEvent', key, control

  _addEvent: (e) ->
    @address.send e

module.exports = KeyboardController

