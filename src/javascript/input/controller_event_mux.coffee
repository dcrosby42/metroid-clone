PressedReleased = require '../utils/pressed_released'
Immutable = require 'immutable'
Map = Immutable.Map

#
# Wraps a map of controller names to their KeyboardController or GamepadController 
# counterparts.  
class ControllerEventMux
  constructor: (controllerMap) ->
    @controllers = Map(controllerMap)
    @state = @controllers.map (c) -> Map()
    # console.log "@controllers:",@controllers.toJS()

  # Calling next() yields an immutable Map from those controller
  # names to the incoming events from their respective controllers, eg,
  #
  #   {
  #     admin: { toggle_pause: true }
  #     playerKeyboard: null
  #     playerGamepad: { action1: true, action2: false }
  #   }
  next: ->
    # state = @state
    @controllers.map (c,k) ->
      events = c.update()
      if events?
        Map(events)
        # e = Immutable.Map(events)
        # e = Immutable.Map(events)
        # s = state.get(k) || Map()
        # state = state.set k, PressedReleased.update(s, e)
      else
        null
    # @state = state
    # @state



    
module.exports = ControllerEventMux
