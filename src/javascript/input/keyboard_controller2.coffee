MousetrapWrapper = require '../vendor/mousetrap_wrapper'
Immutable = require 'immutable'

bindUpDown = (addEvent, type, key,control) ->
  MousetrapWrapper.bind key, (-> addEvent event(type, control, 'down')), 'keydown'
  MousetrapWrapper.bind key, (-> addEvent event(type, control, 'up')), 'keyup'

event = (type, control,action) ->
  {
    type:'ControllerEvent'
    control: control
    action: action
  }

class KeyboardController
  constructor: (@keyControls) ->
    @_actions = []
    for key,control of @keyControls
      bindUpDown @_addEvent.bind(@), 'ControllerEvent', key, control

  _addEvent: (e) ->
    @_actions.push e

  events: ->
    es = Immutable.fromJS(@_actions)
    @_actions.length = 0
    es

module.exports = KeyboardController

