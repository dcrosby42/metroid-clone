PIXI = require "pixi.js"
Immutable = require 'immutable'
ViewObjectSyncSystem = require '../view_object_sync_system'

class RoomSyncSystem extends ViewObjectSyncSystem
  @Subscribe: [ 'room', 'position' ]
  @SyncComponent: 'room'

  newObject: (comps) ->
    roomComp = comps.get('room')
    position = comps.get('position')

    container = new PIXI.DisplayObjectContainer()
    container.position.set position.get('x'), position.get('y')
    container._name = roomComp.get('roomId')

    room = @config.getRoom(roomComp.get('roomId'))
    # console.log "RoomSyncSystem room",room
    @_populateTiles container, room.tiles

    @ui.addObjectToLayer container, 'rooms'
    return container


  updateObject: (comps,sprite) ->
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

module.exports = RoomSyncSystem
