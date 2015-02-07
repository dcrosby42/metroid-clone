PIXI = require 'pixi.js'
_ = require 'lodash'

Mousetrap = require '../vendor/mousetrap_wrapper'
KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')

EntityStore = require '../ecs/entity_store'

SystemRegistry = require '../ecs/system_registry'
CommonSystems = require './systems'
SamusSystems =  require './entity/samus/systems'
EnemiesSystems =  require './entity/enemies/systems'


C = require './entity/components'

Samus = require './entity/samus'
Enemies = require './entity/enemies'

MapData = require './map/map_data'

class MapSpike
  constructor: ->

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

  setupStage: (@stage, width, height) ->
    @layers = @setupLayers()

    @estore = new EntityStore()

    @samusId = @estore.createEntity Samus.factory.createComponents('samus')

    for x in [150, 200, 250, 300, 350]
      @estore.createEntity Enemies.factory.createComponents('basicSkree', x:x, y: 32)

    # Background music:
    # @estore.createEntity [
    #   new C.Sound soundId: 'brinstar', timeLimit: 116000, volume: 0.4
    # ]

    @setupSpriteConfigs()

    @setupInput()

    @setupMap(MapData.areas.a, @layers.map)

    @timeDilation = 1

    @setupSystems()

    window.me = @
    window.estore = @estore
    window.samusId = @samusId
    window.stage = @stage

  setupLayers: ->
    scaler = new PIXI.DisplayObjectContainer()
    scaler.scale.set(2.5,2) # double size, and stretch the actual nintendo 256 px to look like 320

    base = new PIXI.DisplayObjectContainer()

    map = new PIXI.DisplayObjectContainer()

    creatures = new PIXI.DisplayObjectContainer()

    overlay = new PIXI.DisplayObjectContainer()

    @stage.addChild scaler
    scaler.addChild base
    base.addChild map
    base.addChild creatures
    base.addChild overlay

    # layers:
    {
      scaler: scaler
      base: base
      map: map
      creatures: creatures
      overlay: overlay
      default: creatures
    }

  setupInput: ->
    @input =
      controllers:
        player1: {}
        player2: {}
        admin: {}

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

    @gamepadController = new GamepadController
      "DPAD_RIGHT": 'right'
      "DPAD_LEFT": 'left'
      "DPAD_UP": 'up'
      "DPAD_DOWN": 'down'
      "FACE_1": 'jump'
      "FACE_3": 'shoot'

    @useGamepad = false
    @p1Controller = @keyboardController

  setupSpriteConfigs: ->
    @spriteConfigs = {}
    _.merge @spriteConfigs, Samus.sprites
    _.merge @spriteConfigs, Enemies.sprites


  setupSystems: ->
    Systems = new SystemRegistry()
    Systems.register CommonSystems
    Systems.register SamusSystems
    Systems.register EnemiesSystems

    @systemsRunner = Systems.sequence [
      'death_timer_system'
      'visual_timer_system'
      'sound_system'
      'samus_motion'
      'controller_system'
      'samus_controller_action'
      'samus_weapon'
      'samus_action_velocity'
      'samus_action_sounds'
      'skree_action'
      'skree_velocity'
      'gravity_system'
      ['map_physics_system',
        tileGrid: @mapTileGrid
        tileWidth: @mapTileWidth
        tileHeight: @mapTileHeight]

      'bullet_system'

      'samus_animation'
      'skree_animation'

      # 
      # 'output' systems mutate world state (graphics, sounds, browser etc)
      #
      ['sprite_sync_system',
        spriteConfigs: @spriteConfigs
        spriteLookupTable: {}
        layers: @layers ]

      ['samus_viewport_tracker',
        container: @layers.base
        tileGrid: @mapTileGrid
        tileWidth: @mapTileWidth
        tileHeight: @mapTileHeight
        screenWidthInTiles: 16
        screenHeightInTiles: 15
      ]

      ['sound_sync_system',
        soundCache: {} ]
    ]

  update: (dt) ->
    @handleAdminControls()

    p1in = @p1Controller.update()
    # console.log p1in if p1in
    @input.controllers.player1 = p1in
    # @input.controllers.player2 = @p2Controller.update()

    @systemsRunner.run @estore, dt*@timeDilation, @input

  handleAdminControls: ->
    ac = @adminController.update()
    if ac
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
    
  setupMap: (map, container) ->
    @mapTileHeight = 16
    @mapTileWidth = 16

    @roomWidth = 16
    @roomHeight = 15

    @roomWidthPx = @roomWidth * @mapTileWidth
    @roomHeightPx = @roomHeight * @mapTileHeight

    getMapTileSprite = (n) ->
      if n?
        PIXI.Sprite.fromFrame("block-#{n}")
      else
        null

    divRem = (numer,denom) -> [Math.floor(numer/denom), numer % denom]

    mapRowCount = map.length * @roomHeight
    mapColCount = map[0].length * @roomWidth

    tileGrid = []
    for r in [0...mapRowCount]
      tileRow = []
      tileGrid.push tileRow
      for c in [0...mapColCount]
        [rr,tr] = divRem(r, @roomHeight)
        [rc,tc] = divRem(c, @roomWidth)
        roomType = map[rr][rc]
        room = MapData.roomTypes[roomType]
        tileType = room[tr][tc]
        if tileType?
          tile =
            type: tileType
            x: c * @mapTileWidth
            y: r * @mapTileHeight
            width: @mapTileWidth
            height: @mapTileHeight
          
          sprite = getMapTileSprite(tile.type)
          if sprite?
            sprite.position.set tile.x, tile.y
            container.addChild sprite

          tileRow.push tile
        else
          tileRow.push null

    @mapTileGrid = tileGrid
    

module.exports = MapSpike
