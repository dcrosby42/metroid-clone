C = require '../../components'
T = C.Types
Helpers = require './helpers'
{name,tag,buildComp} = Helpers

Enemies = {}

Enemies.basicZoomer = ({position}) ->
  pos_x = position.x + 8
  pos_y = position.y + 8
  [
    name('Zoomer')
    tag('crawley')
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


module.exports = Enemies
