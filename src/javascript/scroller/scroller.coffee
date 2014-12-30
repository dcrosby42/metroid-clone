Far = require './far'
Mid = require './mid'
MapData = require './map_data'
MapBuilder = require './map_builder'

class Scroller
  constructor: (stage) ->
    @far = new Far()
    @mid = new Mid()
    @mapBuilder = new MapBuilder()
    @walls = @mapBuilder.createWalls(MapData.Map1)
    @viewportX = 0

    stage.addChild @far
    stage.addChild @mid
    stage.addChild @walls

  getViewportX: ->
    @viewportX

  setViewportX: (x) ->
    @viewportX = x
    @far.setViewportX(x)
    @mid.setViewportX(x)
    @walls.setViewportX(x)

  moveViewportXBy: (x) ->
    @setViewportX @viewportX + x
    
module.exports = Scroller
