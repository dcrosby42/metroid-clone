C = require '../../components'
T = C.Types
Helpers = require './helpers'
{name,tag,buildComp,emptyComp} = Helpers
# General = require './general'

exports.doorEntities = ({style,x,y,roomId}) ->
  doorFrameComps = [
    name('Door Frame')
    buildComp T.DoorFrame,
      roomId: roomId
    buildComp T.Position,
      x: x
      y: y
    buildComp T.Animation,
      layer: 'doors'
      spriteName: 'door_frame'
      state: 'default'
  ]

  # DOOR GEL

  gx = if style == 'blue-left'
    x + 1  # scoot closer to the door enclosure
  else
    x + 23 # move over to the right edge of the door enclosure
  spriteName = if style == 'blue-left'
    'blue_gel_left'
  else
    'blue_gel_right'

  doorGelComps = [
    name('Door Gel')
    tag('map_fixture')
    buildComp T.DoorGel,
      roomId: roomId
    buildComp T.Position,
      x:gx
      y:y
    buildComp T.Animation,
      layer: 'doors'
      spriteName: spriteName
      state: 'closed'
    buildComp T.HitBox,
      x: gx
      y: y
      width: 8
      height: 48
      anchorX: 1
      anchorY: 0
    buildComp T.HitBoxVisual,
      color: 0x999922
      layer: 'doors'
  ]

  return [
    doorFrameComps
    doorGelComps
  ]


