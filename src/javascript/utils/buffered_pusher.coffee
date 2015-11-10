lengthCondition = (len) -> (buffer,_) -> buffer.length >= len

ident = (buffer,_) -> buffer


class BufferedPusher
  constructor: (@flush=ident, @cond=lengthCondition(10), @state=null) ->
    @buffer = []

  push: (x) ->
    @buffer.push x
    if @cond(@buffer, @state)
      res = @flush(@buffer, @state)
      @buffer = []
      return res
    else
      return null

  clear: ->
    res = @flush(@buffer, @state)
    @buffer = []
    return res


  @Conditions:
    length: lengthCondition

module.exports = BufferedPusher
