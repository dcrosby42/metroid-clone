Immutable = require 'immutable'
BaseSystem = require '../../ecs/base_system'
MathUtils = require '../../utils/math_utils'

class ViewportSystem extends BaseSystem
  @Subscribe: [
    ['viewport_target', 'position']
    ['viewport', 'position']
  ]

  process: ->
    viewport = @getComp('viewport')
    config = viewport.get('config')
    viewportPosition = @getComp('viewport-position')
    targetPosition = @getComp('viewport_target-position')

    worldMap = @input.getIn(['static','worldMap'])
    area = worldMap.searchArea(viewportPosition.get('x'), viewportPosition.get('y'))
    
    viewportX = MathUtils.clamp(
      MathUtils.keepWithin(
        viewportPosition.get('x')
        targetPosition.get('x')
        config.get('trackBufLeft')
        config.get('trackBufRight'))
      area.leftPx()
      area.rightPx())
    
    viewportY = MathUtils.clamp(
      MathUtils.keepWithin(
        viewportPosition.get('y')
        targetPosition.get('y')
        config.get('trackBufTop')
        config.get('trackBufBottom'))
      area.topPx()
      area.bottomPx())

    @updateComp viewportPosition.set('x',viewportX).set('y',viewportY)
    

module.exports = ViewportSystem

