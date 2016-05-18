Items = require('./components')
Common = require('../components')
Immutable = require('immutable')

F = {}

F.powerup = (args) ->
  x = args.position.x
  y = args.position.y
  name = args.powerup.type
  itemId = args.powerup.itemId
  comps = Immutable.List([
    Items.Powerup.merge
      powerupType: name
      itemId: itemId
    Common.Name.merge
      name: "Powerup #{name}"
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
      width: 8
      height: 8
      anchorX: 0.5 # halfway across
      anchorY: 0.5
    Common.HitBoxVisual.merge
      color: 0x33ff33
  ])
  comps

F.maru_mari = (args) ->
  args ?= {}
  args['powerup'] ?= {}
  args.powerup.type = 'maru_mari'
  F.powerup(args)
    .push(Items.MaruMari)

F.missile_container = (args) ->
  args ?= {}
  args['powerup'] ?= {}
  args.powerup.type = 'missile_container'
  F.powerup(args)
    .push(Items.MissileContainer)

  
module.exports =
  createComponents: (entityType, args) ->
    fact = F[entityType]
    if fact?
      fact(args)
    else
      throw new Error("Items.Factory cannot build entityType=",entityType)
