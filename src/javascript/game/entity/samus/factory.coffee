S = require('./components')
Common = require('../components')

samusComps = (args) ->
  [
    new S.Samus
      action: null
      motion: 'standing' # standing | running | jumping | falling
      direction: 'right' # right | left
      aim: 'straight' # up | straight
      runSpeed: 88/1000 # 88 px/sec
      jumpSpeed: 400/1000
      floatSpeed: 60/1000
    new Common.Position(x: 50, y: 50)
    new Common.Velocity(x: 0, y: 0)
    # new Common.Movement()
    new Common.HitBox
      # x: 50 # we're going to rely on Position component for authorotative location
      # y: 50
      width: 12
      height: 32
      anchorX: 0.5
      anchorY: 1
    new Common.Controller(inputName: 'player1')
    new Common.Visual
      layer: 'creatures'
      spriteName: 'samus'
      state: 'stand-right'
      time: 0
  ]

componentFactories =
  samus: samusComps

module.exports =
  createComponents: (entityType, args) ->
    componentFactories[entityType](args)

