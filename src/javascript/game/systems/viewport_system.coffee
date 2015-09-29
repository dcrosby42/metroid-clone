Immutable = require 'immutable'
BaseSystem = require '../../ecs/base_system'
MathUtils = require '../../utils/math_utils'
Common = require '../entity/components'

class ViewportSystem extends BaseSystem
  @Subscribe: [
    ['viewport_target', 'position']
    ['viewport', 'position']
  ]

  process: ->
    viewportPosition = @getComp('viewport-position')
    targetPosition = @getComp('viewport_target-position')
    worldMap = @input.getIn(['static','worldMap'])
    viewport = @getComp('viewport')

    if @_transitionToNewArea(worldMap, viewportPosition, targetPosition)
      return

    viewportArea = worldMap.getAreaAt(viewportPosition.get('x'), viewportPosition.get('y'))
    config = viewport.get('config')

    viewportX = MathUtils.clamp(
      MathUtils.keepWithin(
        viewportPosition.get('x')
        targetPosition.get('x')
        config.get('trackBufLeft')
        config.get('trackBufRight'))
      viewportArea.leftPx()
      viewportArea.rightPx() - config.get('width')
    )
    
    viewportY = MathUtils.clamp(
      MathUtils.keepWithin(
        viewportPosition.get('y')
        targetPosition.get('y')
        config.get('trackBufTop')
        config.get('trackBufBottom'))
      viewportArea.topPx()
      viewportArea.bottomPx() - config.get('height')
    )

    @updateComp viewportPosition.set('x',viewportX).set('y',viewportY)
    
  _transitionToNewArea: (worldMap, viewportPosition, targetPosition) ->
    viewportArea = worldMap.getAreaAt(viewportPosition.get('x'), viewportPosition.get('y'))
    targetArea = worldMap.getAreaAt(targetPosition.get('x'), targetPosition.get('y'))
    
    if targetArea and viewportArea and targetArea.name != viewportArea.name
      # What room are we shuttling to?
      nextRoom = worldMap.getRoomAt(targetPosition.get('x'), targetPosition.get('y'))
      return false if nextRoom.nil?
      # What entity should be re-targeted once we're there?
      viewportTarget = @getComp('viewport_target')
      return false if viewportTarget.nil?

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
      return true

module.exports = ViewportSystem

