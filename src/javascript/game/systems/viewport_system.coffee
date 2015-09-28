Immutable = require 'immutable'
BaseSystem = require '../../ecs/base_system'
MathUtils = require '../../utils/math_utils'

class ViewportSystem extends BaseSystem
  @Subscribe: [
    ['viewport_target', 'position']
    ['viewport', 'position']
  ]

  process: ->
    viewportPosition = @getComp('viewport-position')
    targetPosition = @getComp('viewport_target-position')

    worldMap = @input.getIn(['static','worldMap'])
    viewportArea = worldMap.getAreaAt(viewportPosition.get('x'), viewportPosition.get('y'))
    targetArea = worldMap.getAreaAt(targetPosition.get('x'), targetPosition.get('y'))
    
    if targetArea.name != viewportArea.name
      # What room are we shuttling to?
      nextRoom = worldMap.getRoomAt(targetPosition.get('x'), targetPosition.get('y'))
      # What entity should be re-targeted once we're there?
      viewportTarget = @getComp('viewport_target')
      targetEid = viewportTarget.get('eid')
      # Remove target from entity
      @deleteComp viewportTarget

      # Create a "shuttle"
      @newEntity [
        Common.Name.merge
          name: "Viewport Shuttle"
        Immutable.Map().merge  # TODO: ViewportShuttle component
          type: 'viewport_shuttle'
          destArea: targetArea.name
          thenTarget: targetEid
        Common.Position.merge
          x: viewportPosition.get('x')
          y: viewportPosition.get('y')
        Immutable.Map().merge  # TODO: Destination component
          type: 'destination'
          x: nextRoom.col * worldMap.roomWidthInPx
          y: nextRoom.row * worldMap.roomHeightInPx
      ]
      return

    viewport = @getComp('viewport')
    config = viewport.get('config')

    viewportX = MathUtils.clamp(
      MathUtils.keepWithin(
        viewportPosition.get('x')
        targetPosition.get('x')
        config.get('trackBufLeft')
        config.get('trackBufRight'))
      viewportArea.leftPx()
      viewportArea.rightPx())
    
    viewportY = MathUtils.clamp(
      MathUtils.keepWithin(
        viewportPosition.get('y')
        targetPosition.get('y')
        config.get('trackBufTop')
        config.get('trackBufBottom'))
      viewportArea.topPx()
      viewportArea.bottomPx())

    @updateComp viewportPosition.set('x',viewportX).set('y',viewportY)
    

module.exports = ViewportSystem

