Immutable = require 'immutable'

S = require('./components')
Common = require('../components')


F = {}

F.samus = (args) ->
  pos = args.position || {x:50,y:50}
  [
    S.Samus
    S.ShortBeam
    Common.ViewportTarget
    Common.Name.merge(name: 'Samus')
    Common.Motion
    S.Suit
    Common.Position.merge
      x:pos.x
      y:pos.y
    Common.Velocity
    Common.Gravity.merge
      max: 200/1000
      # accel: (200/1000)/10
      accel: (200/1000)/15
    Common.Vulnerable
    Common.Health.merge
      hp: 30
    Common.MapCollider
    Common.HitBox.merge
      x: 50
      y: 50
      width: 12
      height: 29
      anchorX: 0.5 # halfway across
      anchorY: 1   # all the way at the bottom
    Common.Controller.merge
      inputName: 'player1'
    Common.Animation.merge
      layer: 'creatures'
      spriteName: 'samus'
      state: 'stand-right'
      time: 0
    Common.HitBoxVisual.merge
      color: 0x0099ff
  ]

module.exports =
  createComponents: (entityType, args) ->
    F[entityType](args)

