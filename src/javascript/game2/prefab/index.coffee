C = require '../../components'
{Animation,Position,Velocity,Name,Tag} = C.Types
T = C.Types

buildComp = C.buildCompForType



exports.samus = ->
  [
    buildComp Name, name: 'Samus'
    buildComp Tag, name: 'samus'
    buildComp Tag, name: 'viewport_target'
    buildComp Animation, spriteName: 'samus', state: 'stand-right', layer: 'creatures'
    buildComp T.Controller, inputName: 'player1'

    buildComp Position
    buildComp Velocity
    buildComp T.Suit, pose: 'standing'
    buildComp T.Motion
    buildComp T.Health

    # S.Weapons
    # S.ShortBeam
    # Common.Gravity.merge
    #   max: 0.15
    #   accel: 0.15 / 16
    # Common.Vulnerable
    # Common.Health.merge
    #   hp: 30
    # Common.MapCollider
    buildComp T.HitBox, {
      x: 50
      y: 50
      width: 12
      height: 29
      anchorX: 0.5 # halfway across
      anchorY: 1   # all the way at the bottom
    }
    buildComp T.HitBoxVisual, color: 0x0099ff
  ]
# console.log exports.samus()

exports.hud = ->
  [
    buildComp Name, name: 'HUD'
    buildComp Tag, name: 'hud'
    buildComp T.Label, content: 'E.?', layer: 'overlay'
    buildComp Position, x: 25, y: 35
  ]

exports.collectedItems = ->
  [
    buildComp Name, name: 'Collected Items'
    buildComp T.CollectedItems
  ]
# console.log exports.collectedItems()

  #   Comps.Name.merge(name: 'Collected Items')
  #   Immutable.Map
  #     type: 'collected_items'
  #     itemIds: Immutable.Set()
  # ]

exports.viewport = ->
  [
    buildComp Name, name: 'Viewport'
    buildComp Position
    buildComp T.Viewport, {
      width:          16*16       # 16 tiles wide, 16 px per tile
      height:         15*16       # 15 tiles high, 16 px per tile
      trackBufLeft:   (8*18) - 16
      trackBufRight:  (8*18) + 16
      trackBufTop:    (8*18) - 16
      trackBufBottom: (8*18) + 16
    }
  ]
# console.log exports.viewport()

exports.viewportShuttle = ({position,viewportShuttle,destination}={}) ->
  position ?= {}
  viewportShuttle ?= {}
  destination ?= {}
  destination.name = "destination"
  position.name = "position"
  [
    buildComp Name, name: 'Viewport Shuttle'
    buildComp T.ViewportShuttle, viewportShuttle
    buildComp Position, position
    buildComp Position, destination
  ]

# console.log exports.viewportShuttle(position: {x:5,y:6},destination:{x:7,y:8},viewportShuttle:{destArea:'wat',thenTarget:'dude'})

exports.room = (room) ->
  [
    buildComp Name, name: "Room #{room.id}"
    buildComp T.Room, {
      state: 'begin'
      roomId: room.id
      roomType: room.roomDef.id
      roomRow: room.row
      roomCol: room.col
    }
    buildComp Position,
      x: room.x
      y: room.y
  ]
# console.log exports.room(id:24,roomDef:{id:37},row:5,col:6,x:100,y:200)

exports.roomWatcher = ->
  [
    buildComp Name, name: 'Room watcher'
    buildComp T.RoomWatcher
  ]
# console.log exports.roomWatcher()

exports.rng = ->
  [
    buildComp Name, name: 'mainRandom'
    buildComp T.Rng, state: 123123123
  ]
