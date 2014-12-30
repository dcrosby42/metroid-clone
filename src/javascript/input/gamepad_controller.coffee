Gamepad = require('../vendor/gamepad').Gamepad

#
# TODO: FIX MASSIVE CODE DUPE BTW THIS AND KeyboadController
#

class GamepadWrapper
  constructor: (@keys) ->
    @downs = {}
    for key in @keys
      @downs[key] = @_newTracking()

    @gamepad = new Gamepad()
    @gamepad.bind Gamepad.Event.BUTTON_DOWN, (e) => @_keyDown(e.control)
    @gamepad.bind Gamepad.Event.BUTTON_UP, (e) => @_keyUp(e.control)
    if @gamepad.init()
      0 #
    else
      console.log "Gamepad init FAILED"

  _keyDown: (key) ->
    tracking = @_getDowns(key)
    # console.log "_keyDown #{key}", tracking
    tracking['queued'].push(true)
    false

  _keyUp: (key) ->
    tracking = @_getDowns(key)
    # console.log "_keyUp #{key}", tracking
    tracking['queued'].push(false)
    false

  isActive: (key) ->
    tracking = @_getDowns(key)
    if (tracking['queued'].length > 0)
      v = tracking['queued'].shift()
      tracking['last'] = v

    tracking['last']

  _getDowns: (key) ->
    tracking = @downs[key]
    if !tracking?
      tracking = @_newTracking()
      @downs[key] = tracking
    tracking

  _newTracking: ->
    { queued: [], last: false }

class InputState
  constructor: (@key)->
    @active = false

  update: (keyboardWrapper)->
    oldState = @active
    newState = keyboardWrapper.isActive(@key)
    @active = newState
    if !oldState and newState
      return "justPressed"
    if oldState and !newState
      return "justReleased"
    else
      return null

class GamepadController
  constructor: (@bindings) ->
    @keys = []
    @inputStates = {}
    @actionStates = {}
    for key,action of @bindings
      @keys.push(key)
      @inputStates[key] = new InputState(key)
      @actionStates[key] = false

    @keyboardWrapper = new GamepadWrapper(@keys)

  update: ->
    diff = {}
    change = false
    for key,inputState of @inputStates
      action = @bindings[key]
      res = inputState.update(@keyboardWrapper)
      switch res
        when "justPressed"
          diff[action] = true
          @actionStates[action] = true
          change = true
        when "justReleased"
          diff[action] = false
          @actionStates[action] = false
          change = true
    diff if change

  isActive: (action) ->
    @actionStates[action]


# module.exports = KeyboardController

module.exports = GamepadController
