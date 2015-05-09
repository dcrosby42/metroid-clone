Immutable = require 'immutable'

S = require('./components')
Common = require('../components')


F = {}

F.samus = (args) ->
  [
    S.Samus
    S.ShortBeam
    Common.Position.merge
      x:50
      y:50
    Common.Velocity
    Common.Gravity.merge
      max: 200/1000
      accel: (200/1000)/10
    Common.HitBox.merge
      x: 50
      y: 50
      width: 12
      height: 32
      anchorX: 0.5 # halfway across
      anchorY: 1   # all the way at the bottom
    Common.Controller.merge
      inputName: 'player1'
    Common.Visual.merge
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

