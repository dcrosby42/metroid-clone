Enemy = require('./components')
Common = require('../components2')

F = {}

F.basicSkree = (args) ->
  [
    Common.Enemy
    Enemy.Skree
    Common.Visual.merge
      layer: 'creatures'
      spriteName: 'basic_skree'
      state: 'wait'
      time: 0
    Common.Position.merge
      x: args.x
      y: args.y
    Common.Velocity.merge
      x: 0
      y: 0
    Common.HitBox.merge
      width: 16
      height: 24
      anchorX: 0.5 # halfway across
      anchorY: 0   # all the way at the top
    Common.HitBoxVisual.merge
      color: 0x55FF55
  ]


module.exports =
  createComponents: (entityType, args) ->
    F[entityType](args)

