PIXI = require "pixi.js"
ViewObjectSyncSystem = require '../view_object_sync_system'
C = require '../../components'
T = C.Types

class RoomSyncSystem extends ViewObjectSyncSystem
  @Subscribe: [ T.Room, T.Position ]
  @SyncComponentInSlot: 0
  @CacheName: 'room'

  newObject: (r) ->
    # roomComp = comps.get('room')
    # position = comps.get('position')
    [roomComp,position] = r.comps

    container = new PIXI.DisplayObjectContainer()
    container.position.set position.x, position.y
    container._name = roomComp.roomId

    room = @uiConfig.getRoom(roomComp.roomId)
    # console.log "RoomSyncSystem room",room
    @_populateTiles container, room.tiles

    @uiState.addObjectToLayer container, 'rooms'
    return container


  updateObject: (r,container) ->
    # Nothing?

  _populateTiles: (container, tiles) ->
    for row in tiles
      for tile in row
        if tile
          name = "block-#{tile.type}"
          sprite = PIXI.Sprite.fromFrame(name)
          sprite._name = name
          sprite.width = 16.5
          sprite.height = 16.5
          sprite.position.set tile.x, tile.y
          sprite.visible = true
          container.addChild sprite
        else

module.exports = -> new RoomSyncSystem()
