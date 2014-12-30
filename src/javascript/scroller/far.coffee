PIXI = require 'pixi.js'

class Far extends PIXI.TilingSprite
  @DELTA_X: 0.064

  constructor: ->
    texture = PIXI.Texture.fromImage("images/bg-far.png")
    super texture, 512, 256
    @position.x = 0
    @position.y = 0
    @tilePosition.x = 0
    @tilePosition.y = 0
    @viewportX = 0

  setViewportX: (x) ->
    distanceTravelled = x - @viewportX
    @viewportX = x
    @tilePosition.x -= (distanceTravelled * Far.DELTA_X)

module.exports = Far
