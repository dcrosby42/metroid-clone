Immutable = require 'immutable'
BaseSystem = require '../../ecs/base_system'
MathUtils = require '../../utils/math_utils'

class ViewportSystem extends BaseSystem
  @Subscribe: [
    ['map']
    ['viewport_target', 'position']
    ['viewport', 'position']
  ]

  process: ->
    map = @getComp('map')
    viewport = @getComp('viewport')
    config = viewport.get('config')
    viewportPosition = @getComp('viewport-position')
    targetPosition = @getComp('viewport_target-position')

    # Make sure the viewport config is up-to-date wrt map bounds:
    if map.get('name') != config.get('mapName')
      config = @_getViewportConfig(map.get('name'))
      @updateComp viewport.set('config', config)

    # Move the viewport virtual location (upper-left corner) relative to the target position:
    viewportX = MathUtils.clamp MathUtils.keepWithin(viewportPosition.get('x'), targetPosition.get('x'), config.get('trackBufLeft'), config.get('trackBufRight')), config.get('minX'), config.get('maxX')
    viewportY = MathUtils.clamp MathUtils.keepWithin(viewportPosition.get('y'), targetPosition.get('y'), config.get('trackBufTop'), config.get('trackBufBottom')), config.get('minY'), config.get('maxY')
    @updateComp viewportPosition.set('x',viewportX).set('y',viewportY)
    
  _getViewportConfig: (mapName) ->
    mapDatabase = @input.getIn(['static','mapDatabase'])
    map = mapDatabase.get(mapName)

    config = Immutable.fromJS
      mapName: "base"
      minX: 0
      maxX: (map.tileGrid[0].length - map.screenWidthInTiles) * map.tileWidth
      minY: 0
      maxY: (map.tileGrid.length - map.screenHeightInTiles) * map.tileHeight
      trackBufLeft: 7 * map.tileWidth
      trackBufRight: 9 * map.tileWidth
      trackBufTop: 7 * map.tileHeight
      trackBufBottom: 9 * map.tileHeight
    config
    

module.exports = ViewportSystem

