C = require('./components')
Common = require('../components')

F = {}

# motion
# action
# velocity
# animation

F.basicSkree = (args) ->
  [
    new C.Skree
      action: 'sleep'
    new Common.Position(x: args.x, y: args.y)
    new Common.Velocity(x: 0, y: 0)
    new Common.HitBox
      width: 16
      height: 24
      anchorX: 0.5 # halfway across
      anchorY: 0   # all the way at the top
    new Common.Visual
      layer: 'creatures'
      spriteName: 'basic_skree'
      state: 'wait'
      time: 0
  ]


module.exports =
  createComponents: (entityType, args) ->
    F[entityType](args)

