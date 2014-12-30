PIXI = require 'pixi.js'

class Mid extends PIXI.TilingSprite
  @DELTA_X = 0.32
  constructor: ->
    texture = PIXI.Texture.fromImage("images/bg-mid.png")
    super texture, 512, 256
    @position.x = 0
    @position.y = 128
    @tilePosition.x = 0
    @tilePosition.y = 0
    @viewportX = 0

  setViewportX: (x) ->
    distanceTravelled = x - @viewportX
    @viewportX = x
    @tilePosition.x -= (distanceTravelled * Mid.DELTA_X)

module.exports = Mid
