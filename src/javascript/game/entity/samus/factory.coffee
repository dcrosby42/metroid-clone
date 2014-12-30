S = require('./components')
Common = require('../components')

samusComps = (args) ->
  [
    new S.Samus
      action: 'standing' # standing | running | jumping | falling
      direction: 'right' # right | left
      aim: 'straight' # up | straight
      runSpeed: 88/1000 # 88 px/sec
      jumpSpeed: 200/1000
      floatSpeed: 60/1000
    new Common.Position(x: 50, y: 208)
    new Common.Movement()
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

