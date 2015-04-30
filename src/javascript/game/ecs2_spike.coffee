PIXI = require 'pixi.js'
_ = require 'lodash'
Immutable = require 'immutable'

Mousetrap = require '../vendor/mousetrap_wrapper'
KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')

EntityStore = require '../ecs2/entity_store'
EntityStoreFinder = require '../ecs2/entity_store_finder'
EntityStoreUpdater = require '../ecs2/entity_store_updater'


# SystemRegistry = require '../ecs/system_registry'
SystemRunner = require '../ecs2/system_runner'
OutputSystemRunner = require '../ecs2/output_system_runner'
SystemExpander = require '../ecs2/system_expander'

CommonSystems = require './systems'
SamusSystems =  require './entity/samus2/systems'
EnemiesSystems =  require './entity/enemies/systems'


C = require './entity/components'

Samus = require './entity/samus2'
Enemies = require './entity/enemies'

MapData = require './map/map_data'

Debug = require '../utils/debug'

class Ecs2Spike
  constructor: ({@componentInspector}) ->

  graphicsToPreload: ->
    assets = [
      "images/brinstar.json"
    ]
    assets = assets.concat(Samus.assets)
    assets = assets.concat(Enemies.assets)

    assets

  soundsToPreload: ->
    songs = ["brinstar"]
    effects = [
      "enemy_die1"
      "health"
      "step2"
      "jump"
      "samus_hurt"
      "short_beam"
    ]
    assets = {}
    for song in songs
      assets[song] = "sounds/music/#{song}.mp3"
    for effect in effects
      assets[effect] = "sounds/fx/#{effect}.wav"
    assets

  setupStage: (stage, width, height) ->
    layers = @setupLayers(stage)

    map = @setupMap(
      MapData.areas.a,
      layers.map,
      MapData.info.tileWidth,
      MapData.info.tileHeight)

    @ui = {
      stage: stage
      spriteConfigs: @setupSpriteConfigs()
      viewportConfig: @setupViewportConfig(map)
      layers: layers
      map: map
      spriteCache: {}
      componentInspector: @componentInspector
    }


    @estore = new EntityStore()
    @entityFinder = new EntityStoreFinder(@estore)
    @entityUpdater = new EntityStoreUpdater(@estore)

    @samusId = @estore.createEntity Samus.factory.createComponents('samus')

    # TODO
    # for x in [150, 200, 250, 300, 350]
    #   @estore.createEntity Enemies.factory.createComponents('basicSkree', x:x, y: 32)


    @setupInput(map:map)

    @timeDilation = 1

    @systemRunner       = @setupSystemRunner()
    @outputSystemRunner = @setupOutputSystemRunner()

    window.me = @
    window.estore = @estore
    window.samusId = @samusId
    window.stage = @stage
    window.ui = @ui

  setupLayers: (stage) ->
    scaler = new PIXI.DisplayObjectContainer()
    scaler.scale.set(2.5,2) # double size, and stretch the actual nintendo 256 px to look like 320

    base = new PIXI.DisplayObjectContainer()

    map = new PIXI.DisplayObjectContainer()

    creatures = new PIXI.DisplayObjectContainer()

    overlay = new PIXI.DisplayObjectContainer()

    stage.addChild scaler
    scaler.addChild base
    base.addChild map
    base.addChild creatures
    base.addChild overlay

    layers =
      scaler: scaler
      base: base
      map: map
      creatures: creatures
      overlay: overlay
      default: creatures
    layers

  setupInput: ({map}) ->
    @defaultInput = Immutable.fromJS
      controllers:
        player1: {}
        player2: {}
        admin: {}
      dt: 0
      


    @keyboardController = new KeyboardController
      bindings:
        "right": 'right'
        "left": 'left'
        "up": 'up'
        "down": 'down'
        "a": 'jump'
        "s": 'shoot'
      mutually_exclusive_actions: [
        [ 'right', 'left' ]
        [ 'up', 'down' ]
      ]
        

    @adminController = new KeyboardController
      bindings:
        "g": 'toggle_gamepad'
        "b": 'toggle_bgm'
        "p": 'toggle_pause'
        "d": 'toggle_bounding_box'
        "m": 'cycle_admin_mover'
        "h": 'left'
        "j": 'down'
        "k": 'up'
        "l": 'right'

    @gamepadController = new GamepadController
      "DPAD_RIGHT": 'right'
      "DPAD_LEFT": 'left'
      "DPAD_UP": 'up'
      "DPAD_DOWN": 'down'
      "FACE_1": 'jump'
      "FACE_3": 'shoot'

    @useGamepad = false
    @p1Controller = @keyboardController

    @boundingBoxToggle = {value:true}
    @adminMovers = [ 'mover1','mover2' ]
    @adminMoversIndex = 0

  setupSpriteConfigs: ->
    spriteConfigs = {}
    _.merge spriteConfigs, Samus.sprites
    _.merge spriteConfigs, Enemies.sprites
    spriteConfigs

  setupViewportConfig: (map) ->
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



  setupSystemRunner: ->
    [
      'death_timer_system'
      'visual_timer_system'
      # 'sound_system'
      'samus_motion'
      'controller_system'
      # ['manual_mover_system'
      #   componentType: 'hit_box' ]
      'samus_controller_action'
      'samus_weapon'
      'samus_action_velocity'
      # 'samus_action_sounds'
      # 'skree_action'
      # 'skree_velocity'
      'gravity_system'
      'map_physics_system',

      'bullet_system'

      'samus_animation'
      # 'skree_animation'
    ]

    systems = SystemExpander.expandSystems [
      CommonSystems.death_timer_system
      CommonSystems.visual_timer_system
      SamusSystems.samus_motion
      CommonSystems.controller_system
      SamusSystems.samus_controller_action
      SamusSystems.samus_weapon
      SamusSystems.samus_action_velocity
      CommonSystems.gravity_system
      CommonSystems.map_physics_system
      CommonSystems.bullet_enemy_system
      CommonSystems.bullet_system
      SamusSystems.samus_animation
    ]

    return new SystemRunner(@entityFinder, @entityUpdater, systems)


  setupOutputSystemRunner: ->
    systems = SystemExpander.expandSystems [
      CommonSystems.sprite_sync_system
      CommonSystems.debug_system
      
      # CommonSystems.sound_sync_system,
      # CommonSystems.hit_box_visual_sync_system,
      # SamusSystems.samus_viewport_tracker,
    ]

      # ['sprite_sync_system',
      #   spriteConfigs: @spriteConfigs
      #   spriteLookupTable: {}
      #   layers: @layers ]
      #
      # ['samus_viewport_tracker',
      #   container: @layers.base
      #   tileGrid: @map.tileGrid
      #   tileWidth: @map.tileWidth
      #   tileHeight: @map.tileHeight
      #   screenWidthInTiles: @map.screenWidthInTiles
      #   screenHeightInTiles: @map.screenHeightInTiles
      # ]

      # ['hit_box_visual_sync_system'
      #   cache: {}
      #   layer: @layers.overlay
      #   toggle: @boundingBoxToggle
      # ]

      # ['sound_sync_system',
      #   soundCache: {}
      # ]
    

    new OutputSystemRunner
      entityFinder: @entityFinder
      ui: @ui
      systems: systems


  update: (dt) ->
    p1in = @p1Controller.update()
    ac = @adminController.update()
    @handleAdminControls(ac) if ac?

    # @input.controllers.player1 = p1in
    # @input.controllers[@adminMovers[@adminMoversIndex]] = ac
    # @input.controllers.player2 = @p2Controller.update()

    input = @defaultInput
      .set('dt', dt*@timeDilation)
      .setIn(['controllers','player1'], Immutable.fromJS(p1in))
      .setIn(['static','map'], @ui.map)
    
    # input
    #   dt
    #   controllers
    #     player1

    # TODO @systemsRunner.run(@estore, dt*@timeDilation, @input) unless @paused
    unless @paused
      @systemRunner.run input
      @outputSystemRunner.run input
      @ui.componentInspector.sync()
    # Debug.scratch2 @estore.componentsByCid

  handleAdminControls: (ac) ->
    if ac.toggle_gamepad
      @useGamepad = !@useGamepad
      if @useGamepad
        @p1Controller = @gamepadController
      else
        @p1Controller = @keyboardController

    if ac.toggle_bgm
      if @bgmId?
        @estore.destroyEntity @bgmId
        @bgmId = null
      else
        @bgmId = @estore.createEntity [
          new C.Sound soundId: 'brinstar', timeLimit: 116000, volume: 0.3
        ]

    if ac.toggle_pause
      if @paused
        @paused = false
      else
        @paused = true

    if ac.toggle_bounding_box
      @boundingBoxToggle.value = !@boundingBoxToggle.value

    if ac.cycle_admin_mover
      @adminMoversIndex += 1
      if @adminMoversIndex >= @adminMovers.length
        @adminMoversIndex = 0


  setupMap: (map, container, mapTileWidth, mapTileHeight) ->
    roomWidth = 16
    roomHeight = 15

    getMapTileSprite = (n) ->
      if n?
        PIXI.Sprite.fromFrame("block-#{n}")
      else
        null

    divRem = (numer,denom) -> [Math.floor(numer/denom), numer % denom]

    mapRowCount = map.length * roomHeight
    mapColCount = map[0].length * roomWidth

    tileGrid = []
    for r in [0...mapRowCount]
      tileRow = []
      tileGrid.push tileRow
      for c in [0...mapColCount]
        [rr,tr] = divRem(r, roomHeight)
        [rc,tc] = divRem(c, roomWidth)
        roomType = map[rr][rc]
        room = MapData.roomTypes[roomType]
        tileType = room[tr][tc]
        if tileType?
          tile =
            type: tileType
            x: c * mapTileWidth
            y: r * mapTileHeight
            width: mapTileWidth
            height: mapTileHeight
          
          sprite = getMapTileSprite(tile.type)
          if sprite?
            sprite.position.set tile.x, tile.y
            container.addChild sprite

          tileRow.push tile
        else
          tileRow.push null

    map =
      tileGrid: tileGrid
      tileWidth: mapTileWidth
      tileHeight: mapTileHeight
      screenWidthInTiles: roomWidth
      screenHeightInTiles: roomHeight
    map

      

    

module.exports = Ecs2Spike
