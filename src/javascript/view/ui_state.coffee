SoundController = require '../pixi_ext/sound_controller'
PIXI = require "pixi.js"

class UIState
  @Defaults =
    zoomScale: 2.0
    aspectScale:
      x: 1.25
      y: 1.0
  
  constructor: ({stage, zoomScale, aspectScale}) ->
    @_layers = @_createLayers(stage,zoomScale,aspectScale)
    @_objectCaches = {}
    @_currentMapName = null
    @drawHitBoxes = false

  getLayer: (layerName) ->
    @_layers[layerName] || @_layers.default

  addObjectToLayer: (object,layer) ->
    @getLayer(layer).addChild object
    object

  objectCacheFor: (cacheName) ->
    @_objectCaches[cacheName] ?= {}

  playSound: (soundId) ->
    SoundController.playSound(soundId)

  _createLayers: (stage,zoomScale,aspectScale) ->
    zoomScale ?= @constructor.Defaults.zoomScale
    aspectScale ?= @constructor.Defaults.aspectScale

    scaler = new PIXI.DisplayObjectContainer()
    scaler.scale.set(aspectScale.x * zoomScale, aspectScale.y * zoomScale)

    base = new PIXI.DisplayObjectContainer()

    background = new PIXI.DisplayObjectContainer()

    creatures = new PIXI.DisplayObjectContainer()

    overlay = new PIXI.DisplayObjectContainer()

    stage.addChild scaler
    scaler.addChild base
    base.addChild creatures
    scaler.addChild overlay

    layers =
      scaler: scaler
      base: base
      maps: {}
      background: background
      creatures: creatures
      overlay: overlay
      default: creatures
    layers
    
  # MAPS

  getMapLayer: (mapDatabase, mapName) ->
    layer = @_layers.maps[mapName]
    unless layer?
      layer = @_addMapLayer(mapDatabase, mapName)
    layer

  setMap: (mapDatabase, mapName) ->
    return if @_currentMapName == mapName

    @hideMaps()

    layer = @getMapLayer(mapDatabase, mapName)
    layer.visible = true

    @_currentMapName = mapName

  hideMaps: ->
    @_currentMapName = null
    _.forEach _.values(@_layers.maps), (layer) ->
      layer.visible = false

  _addMapLayer: (mapDatabase,mapName) ->
    mapLayer = new PIXI.DisplayObjectContainer()
    @_layers.base.addChild mapLayer
    @_layers.maps[mapName] = mapLayer

    map = mapDatabase.get(mapName)
    @_populateMapTileSprites map, mapLayer
    mapLayer

  _populateMapTileSprites: (map,layer) ->
    for row in map.tileGrid
      for tile in row
        if tile?
          sprite = @_getMapTileSprite(tile.type)
          if sprite?
            sprite.position.set tile.x, tile.y
            layer.addChild sprite

  _getMapTileSprite: (n) ->
    if n?
      PIXI.Sprite.fromFrame("block-#{n}")
    else
      null


  @create: (a...) -> new @(a...)

module.exports = UIState

