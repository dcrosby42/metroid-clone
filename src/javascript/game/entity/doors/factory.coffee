# General = require('./components')
Common = require('../components')

F = {}

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
    factory = F[entityType]
    if factory?
      return factory(args)
    else
      throw "!! Doors factory: no factory for '#{entityType}'"

