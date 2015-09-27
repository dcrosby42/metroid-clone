Enemy = require('./components')
Common = require('../components')

F = {}

F.basicSkree = (args) ->
  pos_x = args.x + 8
  pos_y = args.y
  [
    Common.Name.merge(name: 'Skree')
    Common.Enemy.merge
      hp: Enemy.Skree.get('max_hp')
    Enemy.Skree
    Common.Harmful.merge
      damage: 8
    Common.Animation.merge
      layer: 'creatures'
      spriteName: 'basic_skree'
      state: 'spinSlow'
      time: 0
    Common.Position.merge
      x: pos_x
      y: pos_y
    Common.Velocity.merge
      x: 0
      y: 0
    Common.MapCollider
    Common.HitBox.merge
      width: 14
      height: 24
      anchorX: 0.5 # halfway across
      anchorY: 0   # all the way at the top
    Common.HitBoxVisual.merge
      color: 0x55FF55
  ]

F.basicZoomer = (args) ->
  pos_x = args.x + 8
  pos_y = args.y + 8
  [
    Common.Name.merge(name: 'Zoomer')
    Common.Enemy.merge
      hp: 10 # TODO
    Enemy.Zoomer
    Enemy.Crawl
    Common.Harmful.merge
      damage: 8
    Common.Animation.merge
      layer: 'creatures'
      spriteName: 'basic_zoomer'
      state: 'crawl-up'
      time: 0
    Common.Position.merge
      x: pos_x
      y: pos_y
    Common.Velocity.merge
      x: 0
      y: 0
    Common.MapCollider
    Common.HitBox.merge
      width: 14
      height: 14
      anchorX: 0.5
      anchorY: 0.5
    Common.HitBoxVisual.merge
      color: 0x55FF55
  ]



module.exports =
  createComponents: (entityType, args) ->
    F[entityType](args)

