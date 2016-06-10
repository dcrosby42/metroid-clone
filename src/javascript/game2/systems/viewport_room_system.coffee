BaseSystem = require '../../ecs2/base_system'
EntitySearch = require '../../ecs2/entity_search'
C = require '../../components'
T = C.Types

class Stack
  constructor: (@capacity) ->
    @_data = new Array(@capacity)
    @_i = 0

  push: (x) ->
    @_data[@_i] = x
    @_i++
    return x

  pop: ->
    if @_i > 0
      x = @_data[@_i]
      @_i--
      return x
    return null

  empty: ->
    @_i == 0

  clear: ->
    @_i = 0

newIds = new Stack(C.RoomWatcher.default().roomIds.length)
lostIds = new Stack(C.RoomWatcher.default().roomIds.length)
existIds = new Stack(C.RoomWatcher.default().roomIds.length)

existIds.push(1)
existIds.push(2)
existIds.push(3)
while !existIds.empty()
  console.log existIds.pop()


class ViewportRoomSystem extends BaseSystem
  @Subscribe: [
    [T.Viewport, T.Position]
    [T.RoomWatcher]
  ]

  process: (viewportRes,watcherRes)->
    [viewport,position] = viewportRes.comps
    [roomWatcher] = watcherRes.comps

    worldMap = @input.get('static').get('worldMap')
    rooms = worldMap.searchRooms(
      position.y, position.x,
      position.y + viewport.height - 1, position.x + viewport.width - 1 # -1 stops from over-reaching TODO: adjust this box to be something more than an exact screen fit?
    )
    window.rooms = rooms # WINDOWDEBUG 

    newIds.clear()
    existIds.clear()
    lostIds.clear()

    roomExisted = false
    for room in rooms
      for curr in roomWatcher.roomIds
        if room.id == curr
          # existing room
          roomExisted = true
          existingIds.push(room.id)
          break
      if !roomExisted
        # new room
        newIds.push(room.id)
      roomExisted = false

    found = false
    for curr in roomWatcher.roomIds
      if curr?
        for room in rooms
          if room.id == curr
            found = true
            break
        if !found
          lostIds.push(curr)
        found = false

    if newIds.empty() and lostIds.empty()
      return

    i = 0
    while !existIds.empty()
      roomWatcher.roomIds[i] = existIds.pop()
      i++
    while !newIds.empty()
      id = newIds.pop()
      # Seek through the room results by room.id:
      for room in rooms
        if room.id == id
          # Create a new Room entity
          @estore.createEntity Prefab.room(room: room)
          roomWatcher.roomIds[i] = id
          i++
          break

    while i < roomWatcher.roomIds.length
      # null out any remaining items in the list
      roomWatcher.roomIds[i] = null

    while !lostIds.empty()
      # EOL Room entities that are no longer on screen
      id = lostIds.pop()
      # TODO: find Room comp(s) in gamestate that have roomId=id and destroy their entities
      searcher = EntitySearch.prepare({type:T.Room,roomId:id}) # TODO figure out how to parameterize searchers
      searcher.run @estore, (r) ->
        @publishEvent r.eid,'gone'


module.exports = -> new ViewportRoomSystem()

