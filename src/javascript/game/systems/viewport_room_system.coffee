Immutable = require 'immutable'
BaseSystem = require '../../ecs/base_system'
MathUtils = require '../../utils/math_utils'

Common = require '../entity/components'
FilterExpander = require '../../ecs/filter_expander'

roomFilter = FilterExpander.expandFilterGroups(['room'])

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
    @setProp 'room_watcher', 'roomIds', currRoomIds

    @_reconcileRoomPresence(worldMap, rooms, prevRoomIds, currRoomIds)

  _reconcileRoomPresence: (worldMap, rooms, prevRoomIds, currRoomIds) ->

    # Find existing rooms that need to go away:
    goneIds = prevRoomIds.subtract(currRoomIds)
    @estore.search(roomFilter).forEach (comps) =>
      room = comps.get('room')
      roomId = room.get('roomId')
      if goneIds.has(roomId)
        @publishEntityEvent room.get('eid'), 'gone'

    # Generate new room entities for each new id
    newIds = currRoomIds.subtract(prevRoomIds)
    newIds.forEach (roomId) =>
      room = _.find(rooms, (r) -> r.roomId == roomId)
      if room?
        @newEntity @_roomComps(room: room)
      else
        console.log "!! ViewportRoomSystem: in adding rooms, the rooms array didn't have roomId #{roomId}", rooms

  _roomComps: (args) ->
    room = args.room
    [
      Common.Name.merge
        name: room.roomId
      Immutable.Map
        type: 'room'
        state: 'begin'
        roomId: room.roomId
        roomType: room.roomType
        roomRow: room.row
        roomCol: room.col
      Common.Position.merge
        x: room.x
        y: room.y
    ]
    

module.exports = ViewportRoomSystem

