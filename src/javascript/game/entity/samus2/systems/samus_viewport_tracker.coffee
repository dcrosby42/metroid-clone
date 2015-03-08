clamp = (x,min,max) ->
  return min if x < min
  return max if x > max
  x

keepWithin = (x,target,minDist,maxDist) ->
  if target - x < minDist # move left to preserve min dist:
    return target - minDist
  else if target - x > maxDist # move right to stay within max dist:
    return target - maxDist
  x # x is already at comfortable distance to target


class SamusViewportTracker
  constructor: ({@container,@tileGrid,@tileWidth,@tileHeight,@screenWidthInTiles,@screenHeightInTiles}) ->
    @minX = 0
    @maxX = (@tileGrid[0].length - @screenWidthInTiles) * @tileWidth
    @minY = 0
    @maxY = (@tileGrid.length - @screenHeightInTiles) * @tileHeight

    @trackBufLeft = 7 * @tileWidth
    @trackBufRight = 9 * @tileWidth
    @trackBufTop = 7 * @tileHeight
    @trackBufBottom = 9 * @tileHeight

  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      position = estore.getComponent(samus.eid, 'position')

      # Let's do the calcs using a "viewport" simulation,
      # where x,y is world coord of upper-left of viewing area:
      #   (because the inverted movement of the actual Pixi container was killing my math brain)
      viewportX = -@container.x
      viewportY = -@container.y

      viewportX = clamp keepWithin(viewportX, position.x, @trackBufLeft, @trackBufRight), @minX, @maxX
      viewportY = clamp keepWithin(viewportY, position.y, @trackBufTop, @trackBufBottom), @minY, @maxY
      
      @container.x = -viewportX
      @container.y = -viewportY

module.exports = SamusViewportTracker


