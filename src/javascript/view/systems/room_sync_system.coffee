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

    room = @config.getRoom(roomComp.get('roomId'))
    @_populateTiles container, room.tiles

    # XXX: temp label
    # style =
    #   font: "normal 10pt arial"
    #   fill: "white"
    # txt = new PIXI.Text(roomComp.get('roomId'), style)
    # txt.position.set 0,0
    # txt.visible = true
    # container.addChild txt

    @ui.addObjectToLayer container, 'rooms'
    return container


  updateObject: (comps,sprite) ->
    # Nothing?

  _populateTiles: (container, tiles) ->
    console.log tiles
    for row in tiles
      for tile in row
        if tile and tile.type?
          sprite = PIXI.Sprite.fromFrame("block-#{tile.type}")
          sprite.position.set tile.x, tile.y
          sprite.visible = true
          # console.log sprite
          container.addChild sprite
        else

module.exports = RoomSyncSystem
