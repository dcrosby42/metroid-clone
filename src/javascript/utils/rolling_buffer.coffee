# Immutable = require 'immutable'
# {Map,List} = Immutable

class RollingBuffer
  constructor: (@maxSize=5*60) ->
    @data = new Array(@maxSize)
    @size = 0
    @left = 0
    @offset = 0
    @offsetI = 0
    
  add: (x) ->
    right = (@left+@size) % @maxSize
    @data[right] = x
    if right == @left and @size > 0
      @left++
      @size--
      if @left >= @maxSize
        @left = 0
    @size++
    @offset = @size-1
    @offsetI = (@left+@offset) % @maxSize
    null

  current: ->
    return null if @size <= 0
    @data[@offsetI]

  offsetTo: (i) ->
    if i < 0
      i = 0
    if i >= @size
      i = @size-1
    @offset = i
    @offsetI = (@left+@offset) % @maxSize
    null
      
  forward: ->
    @offsetTo(@offset+1)
    null

  back: ->
    @offsetTo(@offset-1)
    null

  offsetToStart: ->
    @offsetTo(0)

  offsetToEnd: ->
    @offsetTo(@size-1)

  truncate: ->
    @size = @offset+1


module.exports = RollingBuffer
