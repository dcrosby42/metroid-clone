MouseTrap =require '../vendor/mousetrap_wrapper'

class KeyboardWrapper
  constructor: (@keys) ->
    @downs = {}
    for key in @keys
      @downs[key] = { queued: [], last: false }
      @_bind key
    @newEvent = false

  _bind: (key) ->
    Mousetrap.bind key, (=> @_keyDown(key)), 'keydown'
    Mousetrap.bind key, (=> @_keyUp(key)), 'keyup'
  
  _keyDown: (key) ->
    @newEvent = true
    @downs[key]['queued'].push(true)
    false

  _keyUp: (key) ->
    @newEvent = true
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
  constructor: ({@bindings,mutually_exclusive_actions}) ->
    @keys = []
    @inputStates = {}
    @actionStates = {}
    for key,action of @bindings
      @keys.push(key)
      @inputStates[key] = new InputState(key)
      @actionStates[key] = false

    if mutually_exclusive_actions?
      @excluded_actions_for = {}
      for [action_a, action_b] in mutually_exclusive_actions
        @excluded_actions_for[action_a] = [ action_b ]
        @excluded_actions_for[action_b] = [ action_a ]

    @keyboardWrapper = new KeyboardWrapper(@keys)


  update: ->
    return null if !@keyboardWrapper.newEvent
    @keyboardWrapper.newEvent = false
    diff = {}
    change = false
    for key,inputState of @inputStates
      action = @bindings[key]
      switch inputState.update(@keyboardWrapper)
        when "justPressed"
          @actionStates[action] = true
          diff[action] = true
          if @excluded_actions_for?
            others = @excluded_actions_for[action]
            if others?
              for a in others
                if @actionStates[a]
                  @actionStates[a] = false
                  diff[a] = false
          change = true
        when "justReleased"
          @actionStates[action] = false
          diff[action] = false
          change = true
    @keyboardWrapper.newEvent = false
    if change
      return diff
    else
      return null


  isActive: (action) ->
    @actionStates[action]


module.exports = KeyboardController
