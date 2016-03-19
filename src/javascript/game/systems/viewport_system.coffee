Immutable = require 'immutable'
BaseSystem = require '../../ecs/base_system'
MathUtils = require '../../utils/math_utils'
Common = require '../entity/components'
MapConfig = require '../map/config'

trackTarget = (targetPosition,viewportPosition,viewportArea,config) ->
  viewportX = MathUtils.clamp(
    MathUtils.keepWithin(
      viewportPosition.get('x')
      targetPosition.get('x')
      config.get('trackBufLeft')
      config.get('trackBufRight'))
    viewportArea.bounds.left
    viewportArea.bounds.right - config.get('width') # TODO area.bounds.right
  )
  
  viewportY = MathUtils.clamp(
    MathUtils.keepWithin(
      viewportPosition.get('y')
      targetPosition.get('y')
      config.get('trackBufTop')
      config.get('trackBufBottom'))
    viewportArea.bounds.top # TODO area.bounds
    viewportArea.bounds.bottom - config.get('height') # TODO area.bounds
  )
  return viewportPosition.set('x',viewportX).set('y',viewportY)

shuttleZoneBuffer=32
withinShuttlingDistance = (targetPosition, viewportPosition) ->
  tpx = targetPosition.get('x')
  vpx = viewportPosition.get('x')
  return (tpx - (vpx + MapConfig.roomWidthInPixels) <= shuttleZoneBuffer) and (tpx - vpx >= -shuttleZoneBuffer)

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

    config = viewport.get('config')

    viewportArea = worldMap.getAreaAt(viewportPosition.get('x'), viewportPosition.get('y'))
    targetArea = worldMap.getAreaAt(targetPosition.get('x'), targetPosition.get('y'))
    if !targetArea?
      console.log "!! viewport_system: WTF cannot find viewportArea based on viewportPosition",viewportPosition.toJS()
    if !targetArea?
      console.log "!! viewport_system: WTF cannot find targetArea based on targetPosition",targetPosition.toJS()

    if viewportArea? and targetArea? and (viewportArea.name != targetArea.name)
      if withinShuttlingDistance(targetPosition,viewportPosition)
        @_shuttleToNewArea(worldMap, targetPosition,targetArea, viewportPosition)
        return
      else
        # This will cause trackTarget to directly calculate the proper new viewport
        viewportArea = targetArea

    newViewportPos = trackTarget(targetPosition, viewportPosition, viewportArea, config)
    @updateComp newViewportPos

    
  _shuttleToNewArea: (worldMap, targetPosition, targetArea, viewportPosition ) ->
    # What room are we shuttling to?
    nextRoom = worldMap.getRoomAt(targetPosition.get('x'), targetPosition.get('y'))
    return false if nextRoom.nil?
    # What entity should be re-targeted once we're there?
    viewportTarget = @getComp('viewport_target')
    return false if viewportTarget.nil?

    # Remove the viewport_target component from the currently-tracked entity:
    targetEid = viewportTarget.get('eid')
    @deleteComp viewportTarget

    # Create a "shuttle" 
    @newEntity [
      Common.Name.merge
        name: "Viewport Shuttle"
      Immutable.Map().merge  # TODO: ViewportShuttle component
        type: 'viewport_shuttle'
        destArea: targetArea.name
        thenTarget: targetEid # Which entity to resume tracking after the shuttle ride
      Common.Position.merge
        x: viewportPosition.get('x')
        y: viewportPosition.get('y')
      Immutable.Map().merge  # TODO: Destination component
        type: 'destination'
        x: nextRoom.col * MapConfig.roomWidthInPixels
        y: nextRoom.row * MapConfig.roomHeightInPixels
    ]

module.exports = ViewportSystem

