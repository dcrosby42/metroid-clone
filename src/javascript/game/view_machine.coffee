PIXI = require 'pixi.js'

SystemExpander = require '../ecs/system_expander'
CommonSystems = require './systems'
SamusSystems =  require './entity/samus/systems'

class ViewMachine
  constructor: ({@stage,@mapDatabase,@spriteConfigs,@componentInspector}) ->
    @systems = @_createSystems()

    @spriteCache = {}
    @labelCache = {}
    @soundCache = {}
    @hitBoxVisualCache = {}
    @drawHitBoxes = false
    @currentMapName = null

    @layers = @_createLayers(@stage)

    @viewportConfigs = {}

    window.view = @

  update: (estore) ->
    @systems.forEach (system) =>
      system.get('update')?(estore, @)

    @componentInspector.sync(estore)

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

    # Hide existing maps
    _.forEach _.values(@layers.maps), (container) ->
      container.visible = false

    # Get or create map layer:
    container = @layers.maps[mapName]
    unless container?
      container = @_addMapLayer(@layers, @mapDatabase, mapName)

    container.visible = true
    @currentMapName = mapName
    
  getViewportConfig: (mapName) ->
    cfg = @viewportConfigs[mapName]
    unless cfg?
      map = @mapDatabase.get(mapName)
      cfg = @_setupViewportConfig(map)
      @viewportConfigs[mapName] = cfg
    cfg



  _createSystems: ->
    SystemExpander.expandSystems [
      CommonSystems.map_sync_system
      CommonSystems.animation_sync_system
      CommonSystems.label_sync_system
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

  _createLayers: (stage) ->
    scaler = new PIXI.DisplayObjectContainer()
    scaler.scale.set(2.5,2) # double size, and stretch the actual nintendo 256 px to look like 320

    base = new PIXI.DisplayObjectContainer()

    background = new PIXI.DisplayObjectContainer()

    creatures = new PIXI.DisplayObjectContainer()

    overlay = new PIXI.DisplayObjectContainer()

    stage.addChild scaler
    scaler.addChild base
    base.addChild creatures
    base.addChild overlay

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

