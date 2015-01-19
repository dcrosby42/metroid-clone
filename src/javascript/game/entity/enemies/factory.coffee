C = require('./components')
Common = require('../components')

F = {}

F.basicSkree = (args) ->
  [
    new C.Skree
      type: 'skree' # ?
      motion: 'hanging' # hanging | launching | diving | drilling
    new Common.Position(x: 175, y: 32)
    new Common.Velocity(x: 0, y: 0)
    new Common.HitBox
      width: 12
      height: 32
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

