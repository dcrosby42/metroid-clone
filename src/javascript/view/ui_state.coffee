PIXI = require "pixi.js"

class UIState
  @Defaults =
    zoomScale: 2.0
    aspectScale:
      x: 1.25
      y: 1.0
  
  constructor: ({stage, zoomScale, soundController, aspectScale}) ->
    @_layers = @_createLayers(stage,zoomScale,aspectScale)
    @_objectCaches = {}
    @_currentMapName = null
    @drawHitBoxes = false
    @soundController = soundController

  getLayer: (layerName) ->
    @_layers[layerName] || @_layers.default

  addObjectToLayer: (object,layer) ->
    @getLayer(layer).addChild object
    object

  objectCacheFor: (cacheName) ->
    @_objectCaches[cacheName] ?= {}

  playSound: (soundId) ->
    @soundController.playSound(soundId)

  _createLayers: (stage,zoomScale,aspectScale) ->
    zoomScale ?= @constructor.Defaults.zoomScale
    aspectScale ?= @constructor.Defaults.aspectScale

    scaler = new PIXI.DisplayObjectContainer()
    scaler.scale.set(aspectScale.x * zoomScale, aspectScale.y * zoomScale)
    scaler._name = "Scaler Layer - (#{scaler.scale.x},#{scaler.scale.y})"

    base = new PIXI.DisplayObjectContainer()
    base._name = "Base Layer"

    background = new PIXI.DisplayObjectContainer()
    background._name = "Background Layer"

    creatures = new PIXI.DisplayObjectContainer()
    creatures._name = "Creatures Layer"

    rooms = new PIXI.DisplayObjectContainer()
    rooms._name = "Rooms Layer"

    doors = new PIXI.DisplayObjectContainer()
    doors._name = "Doors Layer"

    overlay = new PIXI.DisplayObjectContainer()
    overlay._name = "Overlay Layer"

    stage.addChild scaler
    scaler.addChild base
    base.addChild creatures
    base.addChild rooms
    base.addChild doors
    scaler.addChild overlay

    layers =
      scaler: scaler
      base: base
      maps: {}
      rooms: rooms
      doors: doors
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

  muteAudio: ->
    @soundController.muteAll()

  unmuteAudio: ->
    @soundController.unmuteAll()

  _addMapLayer: (mapDatabase,mapName) ->
    mapLayer = new PIXI.DisplayObjectContainer()
    mapLayer._name = "Map Layer - #{mapName}"
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
            sprite._name = "Sprite #{tile.type}"
            layer.addChild sprite

  _getMapTileSprite: (n) ->
    if n?
      PIXI.Sprite.fromFrame("block-#{n}")
    else
      null


  @create: (a...) -> new @(a...)

module.exports = UIState

