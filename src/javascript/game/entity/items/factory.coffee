Items = require('./components')
Common = require('../components')

F = {}

F.powerup = (args) ->
  console.log args
  x = args.position.x
  y = args.position.y
  name = args.name
  comps = [
    Common.Name.merge
      name: "'#{name}' Powerup"
    Items.Powerup.merge
      name: name
    Common.Position.merge
      x: x
      y: y
    Common.Animation.merge
      layer: 'creatures'
      spriteName: name
      state: 'default'

    Common.HitBox.merge
      x: x
      y: y
      width: 5
      height: 5
      anchorX: 0.5 # halfway across
      anchorY: 0.5
    Common.HitBoxVisual.merge
      color: 0x33ff33
  ]
  comps
# F.healthPickup = (args) ->
#   x = args.x - 16
#   y = args.y - 16
#   value = args.value
#   value ?= 5
#   comps = [
#     Common.Animation.merge
#       layer: 'creatures'
#       spriteName: 'health_drop'
#       state: 'default'
#     Common.Position.merge
#       x: x
#       y: y
#     Common.Pickup.merge
#       item: 'health'
#       value: value
#     Common.HitBoxVisual.merge
#       layer: 'creatures'
#       color: 0xcccccc
#     Common.HitBox.merge
#       x: x
#       y: y
#       width: 8
#       height: 8
#       anchorX: -1.75 + 2.5*(0.0625)
#       anchorY: -1.75 + 0.0625
#   ]
#   if args.time?
#     comps.push Common.DeathTimer.merge(time: args.time)
#   comps

module.exports =
  createComponents: (entityType, args) ->
    F[entityType](args)

