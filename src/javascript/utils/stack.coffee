
class Stack
  constructor: (@capacity) ->
    @_data = new Array(@capacity)
    @_i = 0

  push: (x) ->
    @_data[@_i] = x
    @_i++
    return x

  pop: ->
    if @_i > 0
      @_i--
      x = @_data[@_i]
      return x
    return null

  empty: ->
    @_i == 0

  clear: ->
    @_i = 0

module.exports = Stack
