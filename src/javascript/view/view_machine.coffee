PIXI = require 'pixi.js'
Immutable = require 'immutable'

GameSystems = require '../game/systems'
# SamusSystems =  require './entity/samus/systems'
ViewSystems = require './systems'

DefaultAspectScale =
  x: 1.25
  y: 1.0

class ViewMachine
  constructor: ({@stage,@mapDatabase,@spriteConfigs,@zoomScale,@aspectScale}) ->
    @zoomScale ?= 2.0
    @aspectScale ?= DefaultAspectScale
    @systems = @_createSystems()

    @displayObjectCaches = {}

    @drawHitBoxes = false
    @currentMapName = null

    @layers = @_createLayers(@stage)

    @viewportConfigs = {}

    window.view = @


  # TODO: accept "ui state" as a paramter instead of using ViewMachine itself?
  update: (estore) ->
    @systems.forEach (system) =>
      system.update(@, estore)

    # TODO: move this out of viewMachine altogether?
    # XXX @componentInspector.sync(estore)

    #TODO: return [uiState, events] ??

  objectCacheFor: (cacheName) ->
    cache = @displayObjectCaches[cacheName]
    unless cache?
      cache = {}
      @displayObjectCaches[cacheName] = cache
    cache

  addObjectToLayer: (object,layer) ->
    container = @layers[layer] || @layers['default']
    container.addChild object
    object

  getSpriteConfig: (name) ->
    @spriteConfigs[name]

  getMapLayer: (mapName) ->
    console.log "getMapLayer #{mapName}"
    layer = layers.maps[mapName]
    unless layer?
      layer = @_addMapLayer(layers, @mapDatabase, mapName)
    layer

  setMap: (mapName) ->
    return if @currentMapName == mapName

    @hideMaps()

    # Get or create map layer:
    container = @layers.maps[mapName]
    unless container?
      container = @_addMapLayer(@layers, @mapDatabase, mapName)

    container.visible = true
    @currentMapName = mapName

  hideMaps: ->
    @currentMapName = null
    _.forEach _.values(@layers.maps), (container) ->
      container.visible = false
    
  getViewportConfig: (mapName) ->
    cfg = @viewportConfigs[mapName]
    unless cfg?
      map = @mapDatabase.get(mapName)
      cfg = @_setupViewportConfig(map)
      @viewportConfigs[mapName] = cfg
    cfg



  _createSystems: ->
    window.vs = ViewSystems
    systemDefs = [
      ViewSystems.map_sync_system
      ViewSystems.animation_sync_system
      ViewSystems.label_sync_system
      ViewSystems.ellipse_sync_system
      ViewSystems.rectangle_sync_system
      ViewSystems.hit_box_visual_sync_system
      ViewSystems.viewport_target_tracker_system
      ViewSystems.sound_sync_system
      #XXX ViewSystems.component_inspector_system
    ]
    Immutable.List(systemDefs).map (s) -> s.createInstance()

  _setupViewportConfig: (map) ->
   config =
     layerName: "base"
     minX: 0
     maxX: (map.tileGrid[0].length - map.screenWidthInTiles) * map.tileWidth
     minY: 0
     maxY: (map.tileGrid.length - map.screenHeightInTiles) * map.tileHeight
     trackBufLeft: 7 * map.tileWidth
     trackBufRight: 9 * map.tileWidth
     trackBufTop: 7 * map.tileHeight
     trackBufBottom: 9 * map.tileHeight
   config

  _createLayers: (stage) ->
    scaler = new PIXI.DisplayObjectContainer()
    scaler.scale.set(@aspectScale.x * @zoomScale, @aspectScale.y * @zoomScale) 

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

  _addMapLayer: (layers,mapDatabase,mapName) ->
    mapLayer = new PIXI.DisplayObjectContainer()
    layers.base.addChild mapLayer
    layers.maps[mapName] = mapLayer
    console.log "Added layer #{mapName}", mapLayer
    window.wtf = layers

    map = mapDatabase.get(mapName)
    @_populateMapTileSprites map, mapLayer
    mapLayer


  _getMapTileSprite: (n) ->
    if n?
      PIXI.Sprite.fromFrame("block-#{n}")
    else
      null

  _populateMapTileSprites: (map,container) ->
    for row in map.tileGrid
      for tile in row
        if tile?
          sprite = @_getMapTileSprite(tile.type)
          if sprite?
            sprite.position.set tile.x, tile.y
            container.addChild sprite

module.exports = ViewMachine

