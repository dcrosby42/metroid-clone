PIXI = require 'pixi.js'

SystemExpander = require '../ecs/system_expander'
EntityStoreFinder = require '../ecs/entity_store_finder'
CommonSystems = require './systems'
SamusSystems =  require './entity/samus/systems'

class View
  constructor: ({@stage,@maps,@spriteConfigs,@componentInspector}) ->
    @spriteCache = {}
    @soundCache = {}
    @hitBoxVisualCache = {}
    @drawHitBoxes = false
    @currentMapName = null

    @layers = @_createLayers(@stage, @maps)

    @viewportConfigs = {}
    @maps.forEach (map,mapName) =>
      @viewportConfigs[mapName] = @_setupViewportConfig(map)

    @systems = @_createSystems()
    @_entityStoreFinder = new EntityStoreFinder()

  update: (estore) ->
    @_entityStoreFinder.setEntityStore(estore)

    @systems.forEach (system) =>
      system.get('update')?(@_entityStoreFinder, null, @)

    @_entityStoreFinder.unsetEntityStore()

    @componentInspector.sync(estore)


  _createSystems: ->
    SystemExpander.expandSystems [
      CommonSystems.map_sync_system
      CommonSystems.sprite_sync_system
      CommonSystems.hit_box_visual_sync_system
      SamusSystems.samus_viewport_tracker

      CommonSystems.sound_sync_system

      CommonSystems.debug_system
    ]

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

  _createLayers: (stage, maps) ->
    scaler = new PIXI.DisplayObjectContainer()
    scaler.scale.set(2.5,2) # double size, and stretch the actual nintendo 256 px to look like 320

    base = new PIXI.DisplayObjectContainer()

    mapLayers = {}
    maps.forEach (map, mapName) =>
      mapLayer = new PIXI.DisplayObjectContainer()
      mapLayers[mapName] = mapLayer
      base.addChild mapLayer
      @_populateMapTileSprites map, mapLayer

    creatures = new PIXI.DisplayObjectContainer()

    overlay = new PIXI.DisplayObjectContainer()

    stage.addChild scaler
    scaler.addChild base
    base.addChild creatures
    base.addChild overlay

    layers =
      scaler: scaler
      base: base
      maps: mapLayers
      creatures: creatures
      overlay: overlay
      default: creatures
    layers

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

module.exports = View

