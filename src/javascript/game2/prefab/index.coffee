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
    buildComp T.Label, content: 'E.?'
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

exports.roomWatcher = ->
  [
    buildComp Name, name: 'Room watcher'
    # buildComp RoomWatcher
  ]
# console.log exports.roomWatcher()
  # estore.createEntity [
  #   Comps.Name.merge(name: "Room Watcher")
  #   Immutable.Map
  #     type: 'room_watcher'
  #     roomIds: Immutable.Set()
  # ]

exports.rng = ->
  [
    buildComp Name, name: 'mainRandom'
    buildComp T.Rng, state: 123123123
  ]
