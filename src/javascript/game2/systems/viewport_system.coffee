BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'

# Immutable = require 'immutable'
# Common = require '../entity/components'

MathUtils = require '../../utils/math_utils'
MapConfig = require '../../game/map/config'


class ViewportSystem extends BaseSystem
  @Subscribe: [
    [{type:T.Tag,name:'viewport_target'}, T.Position]
    [T.Viewport, T.Position]
  ]

  process: (target,viewportRes)->
    [viewportTarget,targetPosition] = target.comps
    [viewport,viewportPosition] = viewportRes.comps

    worldMap = @input.getIn(['static','worldMap'])

    viewportArea = worldMap.getAreaAt(viewportPosition.x, viewportPosition.y)
    targetArea = worldMap.getAreaAt(targetPosition.x, targetPosition.y)
    if !targetArea?
      console.log "!! viewport_system: WTF cannot find targetArea based on targetPosition",targetPosition
      throw new Error("Can't get targetArea (see console error)")

    if viewportArea? and targetArea? and (viewportArea.name != targetArea.name) and withinShuttlingDistance(targetPosition,viewportPosition)
      # @_shuttleToNewArea(worldMap, targetPosition, targetArea, viewportPosition, target)
      nextRoom = worldMap.getRoomAt(targetPosition.x, targetPosition.y)
      if nextRoom?
        target.entity.deleteComponent(viewportTarget)

        @estore.createEntity Prefab.viewportShuttle(
          position: viewportPosition
          viewportShuttle:
            destArea: targetArea.name
            thenTarget: target.eid
          destination:
            x: nextRoom.col * MapConfig.roomWidthInPixels
            y: nextRoom.row * MapConfig.roomHeightInPixels)

        # @newEntity [
        #   buildComp Prefab
        #   Common.Name.merge
        #     name: "Viewport Shuttle"
        #   Immutable.Map().merge  # TODO: ViewportShuttle component
        #     type: 'viewport_shuttle'
        #     destArea: targetArea.name
        #     thenTarget: targetEid # Which entity to resume tracking after the shuttle ride
        #   Common.Position.merge
        #     x: viewportPosition.get('x')
        #     y: viewportPosition.get('y')
        #   Immutable.Map().merge  # TODO: Destination component
        #     type: 'destination'
        #     x: nextRoom.col * MapConfig.roomWidthInPixels
        #     y: nextRoom.row * MapConfig.roomHeightInPixels
        # ]

    else
      # just jump to targetArea
      viewportArea = targetArea

      # Track target
      viewportPosition.x = MathUtils.clamp(
        MathUtils.keepWithin(
          viewportPosition.x
          targetPosition.x
          viewport.trackBufLeft
          viewport.trackBufRight)
        viewportArea.bounds.left
        viewportArea.bounds.right - viewport.width
      )
  
      viewportPosition.y = MathUtils.clamp(
        MathUtils.keepWithin(
          viewportPosition.y
          targetPosition.y
          viewport.trackBufTop
          viewport.trackBufBottom)
        viewportArea.bounds.top
        viewportArea.bounds.bottom - viewport.height
      )

shuttleZoneBuffer=32
withinShuttlingDistance = (targetPosition, viewportPosition) ->
  tpx = targetPosition.x
  vpx = viewportPosition.x
  return (tpx - (vpx + MapConfig.roomWidthInPixels) <= shuttleZoneBuffer) and (tpx - vpx >= -shuttleZoneBuffer)
    
module.exports = -> new ViewportSystem()

