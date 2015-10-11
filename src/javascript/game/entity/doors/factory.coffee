Common = require('../components')
DoorComponents = require('./components')

F = {}

F.doorEnclosure = ({x,y,style, roomId}) ->
  [
    Common.Name.merge(name: 'Door Frame')
    DoorComponents.DoorFrame.merge
      roomId: roomId
    Common.Position.merge
      x:x
      y:y
    Common.Animation.merge
      layer: 'doors'
      spriteName: 'door_frame'
      state: 'default'
  ]

F.doorGel = ({x,y,style,roomId}) ->
  gx = if style == 'blue-left'
    x + 1  # scoot closer to the door enclosure
  else
    x + 23 # move over to the right edge of the door enclosure
  spriteName = if style == 'blue-left'
    'blue_gel_left'
  else
    'blue_gel_right'

  [
    Common.Name.merge(name: 'Door Gel')
    DoorComponents.DoorGel.merge
      roomId: roomId
    Common.Position.merge
      x:gx
      y:y
    Common.Animation.merge
      layer: 'doors'
      spriteName: spriteName
      state: 'closed'
    Common.HitBox.merge
      x: gx
      y: y
      width: 8
      height: 48
      anchorX: 1
      anchorY: 0
    Common.HitBoxVisual.merge
      color: 0x999922
      layer: 'doors'
    Common.MapFixture
  ]

module.exports =
  createComponents: (entityType, args) ->
    factory = F[entityType]
    if factory?
      return factory(args)
    else
      throw "!! Doors factory: no factory for '#{entityType}'"

