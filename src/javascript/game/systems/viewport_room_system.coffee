Immutable = require 'immutable'
BaseSystem = require '../../ecs/base_system'
MathUtils = require '../../utils/math_utils'

class ViewportRoomSystem extends BaseSystem
  @Subscribe: [
    ['viewport', 'position']
    ['room_watcher']
  ]

  process: ->

    viewport = @getComp('viewport')
    config = viewport.get('config')
    position = @getComp('viewport-position')

    worldMap = @input.getIn(['static','worldMap'])
    rooms = worldMap.searchRooms(
      position.get('y'), position.get('x'),
      position.get('y')+config.get('height') - 1, position.get('x')+config.get('width') - 1 # -1 stops from over-reaching TODO: adjust this box to be something more than an exact screen fit?
    )

    prevRoomIds = @getProp('room_watcher', 'roomIds')
    currRoomIds = Immutable.Set(_.map(rooms, (r) -> r.id()))

    @_reconcileRoomPresence(worldMap, prevRoomIds, currRoomIds)

    @setProp 'room_watcher', 'roomIds', currRoomIds

  @_reconcileRoomPresence: (worldMap, prevRoomIds, currRoomIds) ->
    goneIds = prevRoomIds.subtract(currRoomIds)
    newIds = currRoomIds.subtract(prevRoomIds)


module.exports = ViewportRoomSystem

