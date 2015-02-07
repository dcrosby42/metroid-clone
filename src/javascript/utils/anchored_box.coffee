# x, y, width, height, left, top, bottom, right, anchorX, anchorY, leftOffset, rightOffset, topOffset, bottomOffset
class AnchoredBox
  constructor: ({@x,@y,@width,@height,@anchorX,@anchorY}) ->
    @_updateLeftRightOffsets()
    @_updateTopBottomOffsets()
    @_updateLeftRight()
    @_updateTopBottom()

  setX: (@x) ->
    @_updateLeftRight()
    @

  moveX: (dx) ->
    @x += dx
    @_updateLeftRight()
    @

  setY: (@y) ->
    @_updateTopBottom()
    @

  moveY: (dy) ->
    @y += dy
    @_updateTopBottom()
    @

  setXY: (@x,@y) ->
    @_updateLeftRight()
    @_updateTopBottom()
    @

  overlaps: (other) ->
    !((@right < other.left) or
      (@left > other.right) or
      (@top < other.buttom) or
      (@bottom > other.top))

  _updateLeftRight: ->
    @left = @x + @leftOffset
    @right = @left + @width

  _updateTopBottom: ->
    @top = @y + @topOffset
    @bottom = @top + @height

  _updateLeftRightOffsets: ->
    @leftOffset   = -(@anchorX * @width)
    @rightOffset  = ((1 - @anchorX) * @width)

  _updateTopBottomOffsets: ->
    @topOffset    = -(@anchorY * @height)
    @bottomOffset = ((1 - @anchorY) * @height)

module.exports = AnchoredBox

