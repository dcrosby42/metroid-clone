MouseTrap =require '../vendor/mousetrap_wrapper'

class KeyboardWrapper
  constructor: (@keys) ->
    @downs = {}
    for key in @keys
      @downs[key] = { queued: [], last: false }
      @_bind key

  _bind: (key) ->
    Mousetrap.bind key, (=> @_keyDown(key)), 'keydown'
    Mousetrap.bind key, (=> @_keyUp(key)), 'keyup'
  
  _keyDown: (key) ->
    @downs[key]['queued'].push(true)
    false

  _keyUp: (key) ->
    @downs[key]['queued'].push(false)
    false

  isActive: (key) ->
    if (@downs[key]['queued'].length > 0)
      v = @downs[key]['queued'].shift()
      @downs[key]['last'] = v

    @downs[key]['last']


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

class KeyboardController
  constructor: (@bindings) ->
    @keys = []
    @inputStates = {}
    @actionStates = {}
    for key,action of @bindings
      @keys.push(key)
      @inputStates[key] = new InputState(key)
      @actionStates[key] = false

    @keyboardWrapper = new KeyboardWrapper(@keys)

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


module.exports = KeyboardController
