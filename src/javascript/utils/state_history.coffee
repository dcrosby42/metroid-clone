Immutable = require 'immutable'

class StateHistory
  constructor: ->
    @maxSize = 5 * 60
    @states = Immutable.List()
    @indexToEnd()

  indexToEnd: ->
    if @states.size > 0
      @index = @states.size - 1
    else
      @index = 0
    @

  addState: (state) ->
    @states = @states.push(state)
    while @states.size > @maxSize
      @states = @states.shift()
    @indexToEnd()
    @

  stepBack: ->
    if @index > 0
      @index -= 1
    @currentState()
    
  stepForward: ->
    if @index < @states.size - 1
      @index += 1
    @currentState()

  currentState: ->
    @states.get(@index)

  newFromHere: ->
    while @states.size - 1 > @index
      @states = @states.pop()

    
module.exports = StateHistory
