C = require '../../components'
T = C.Types
Helpers = require './helpers'
{name,tag,buildComp} = Helpers

General = require './general'

Enemies = {}

Enemies.basicZoomer = ({position}) ->
  pos_x = position.x + 8
  pos_y = position.y + 8
  [
    name('Zoomer')
    # tag('crawley')
    tag('map_collider')
    buildComp T.Enemy, hp: 10
    buildComp T.Zoomer, {
      orientation: 'up'
      crawlDir: 'forward'
    }
    buildComp T.Harmful, damage: 8
    buildComp T.Animation, {
      layer: 'creatures'
      spriteName: 'basic_zoomer'
      state: 'crawl-up'
      time: 0
    }
    buildComp T.Position, {
      x: pos_x
      y: pos_y
    }
    buildComp T.Velocity, {
      x: 0
      y: 0
    }
    buildComp T.HitBox, {
      width: 14
      height: 14
      anchorX: 0.5
      anchorY: 0.5
    }
    buildComp T.HitBoxVisual, color: 0x55FF55
  ]

Enemies.basicSkree = ({position}) ->
  pos_x = position.x + 8
  pos_y = position.y
  [
    name('Skree')
    tag('map_collider')
    buildComp T.Enemy, hp: 10
    buildComp T.Skree
    buildComp T.Animation, {
      layer: 'creatures'
      spriteName: 'basic_skree'
      state: 'spinSlow'
      time: 0
    }
    buildComp T.Position, x: pos_x, y: pos_y
    buildComp T.Velocity
    buildComp T.Harmful, damage: 8
    buildComp T.HitBox, {
      width: 14
      height: 24
      anchorX: 0.5 # halfway across
      anchorY: 0   # all the way at the top
    }
    buildComp T.HitBoxVisual, color: 0x55FF55
  ]

Enemies.skreeShrapnel = ({position,velocity}) ->
  comps = [
    buildComp T.Animation, {
        layer: 'creatures'
        spriteName: 'skree_shrapnel'
        state: 'normal'
    }
    tag('map_ghost')
    buildComp T.Position, position
    buildComp T.Velocity, velocity
    buildComp T.Harmful, damage: 5
    buildComp T.HitBox, {
      width: 7
      height: 7
      anchorX: 0.54
      anchorY: 0.54
    }
    buildComp T.HitBoxVisual
  ]
  return comps.concat(General.deathTimer(100))

module.exports = Enemies
