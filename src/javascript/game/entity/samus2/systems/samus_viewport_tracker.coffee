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

updateContainerPosition = (container,position,viewportConfig) ->
  # Let's do the calcs using a "viewport" simulation,
  # where x,y is world coord of upper-left of viewing area:
  #   (because the inverted movement of the actual Pixi container was killing my math brain)
  viewportX = -container.x
  viewportY = -container.y

  viewportX = clamp keepWithin(viewportX, position.x, viewportConfig.trackBufLeft, viewportConfig.trackBufRight), viewportConfig.minX, viewportConfig.maxX
  viewportY = clamp keepWithin(viewportY, position.y, viewportConfig.trackBufTop, viewportConfig.trackBufBottom), viewportConfig.minY, viewportConfig.maxY
  
  container.x = -viewportX
  container.y = -viewportY
  null

module.exports =
  # type: 'iterating-game-ui' # TODO 
  #
  # config:
  #   filters: [ 'samus', 'position' ] # TODO

  update: (entityFinder, input, ui) ->
    entityFinder.search([ 'samus', 'position' ]).forEach (comps) ->
      position = comps.get('position')
      viewportConfig = ui.viewportConfig
      container = ui.layers[viewportConfig.layerName]
      updateContainerPosition container, position, viewportConfig
