Gamepad = require('../vendor/gamepad').Gamepad

ControllerEvent = require './controller_event'

exports.bindButtons = (address, mappings) ->
  sendMapped = (e,action) ->
    if mapped = mappings[e.control]
      address.send ControllerEvent.create(mapped, action)

  gamepad = new Gamepad()
  gamepad.bind Gamepad.Event.BUTTON_DOWN, (e) -> sendMapped(e,'down')
  gamepad.bind Gamepad.Event.BUTTON_UP, (e) -> sendMapped(e,'up')
  if !gamepad.init()
    throw "GamepadWrapper: Gamepad#init FAILED"



