PIXI = require 'pixi.js'
_ = require 'lodash'

Mousetrap = require '../vendor/mousetrap_wrapper'
KeyboardController = require '../input/keyboard_controller'
# GamepadController = require('../input/gamepad_controller')

EntityStore = require '../ecs/entity_store'
Systems = require './systems'

Samus = require './entity/samus'

class MapSpike
  constructor: ->

  graphicsToPreload: ->
    assets = [
      "images/brinstar.json"
    ]
    assets = assets.concat(Samus.assets)

    assets

  setupStage: (@stage, width, height) ->
    @layers = @setupLayers()

    @estore = new EntityStore()

    @samusId = @estore.createEntity Samus.factory.createComponents('samus')

    @setupSpriteConfigs()

    @setupInput()

    @setupMap(@layers['map'])

    @timeDilation = 1

    @setupSystems()

    window.me = @
    window.estore = @estore
    window.samusId = @samusId
    window.stage = @stage

  setupLayers: ->
    base = new PIXI.DisplayObjectContainer()
    base.scale.set(2.5,2) # double size, and stretch the actual nintendo 256 px to look like 320

    map = new PIXI.DisplayObjectContainer()

    creatures = new PIXI.DisplayObjectContainer()

    overlay = new PIXI.DisplayObjectContainer()

    @stage.addChild base
    base.addChild map
    base.addChild creatures
    base.addChild overlay

    # layers:
    {
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

    # @gamepadController = new GamepadController
    #   "DPAD_RIGHT": 'right'
    #   "DPAD_LEFT": 'left'
    #   "DPAD_UP": 'up'
    #   "DPAD_DOWN": 'down'
    #   "FACE_1": 'jump'
    #   "FACE_3": 'shoot'

    @useGamepad = false
    @p1Controller = @keyboardController

  setupSpriteConfigs: ->
    @spriteConfigs = {}
    _.merge @spriteConfigs, Samus.sprites

    @spriteLookupTable = {}

  setupSystems: ->
    @systemsRunner = Systems.sequence [
      'samus_motion'
      'controller'
      'samus_controller_action'
      'samus_action_velocity'
      ['map_physics',
        # spriteGrid: @mapSpriteGrid
        spriteGrid: @mapTileGrid
        tileWidth: @mapTileWidth
        tileHeight: @mapTileHeight]
      'samus_animation'

      ['sprite_sync',
        spriteConfigs: @spriteConfigs
        spriteLookupTable: @spriteLookupTable
        layers: @layers ]
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
    # if ac and ac.toggle_gamepad
    #   @useGamepad = !@useGamepad
    #   if @useGamepad
    #     @p1Controller = @gamepadController
    #   else
    #     @p1Controller = @keyboardController
    
  setupMap: (container) ->
    @mapTileHeight = 16
    @mapTileWidth = 16

    spriteRows = []
    tileRows = []
    for row,r in roomTypes[0]
      spriteRow = []
      spriteRows.push spriteRow
      tileRow = []
      tileRows.push tileRow
      for bnum,c in row
        if bnum?
          sprite = PIXI.Sprite.fromFrame("block-#{bnum}")
          x = c*@mapTileWidth
          y = r*@mapTileHeight
          sprite.position.set x, y
          container.addChild sprite
          spriteRow.push sprite
          tileRow.push
            x: x
            y: y
            width: @mapTileWidth
            height: @mapTileHeight

        else
          spriteRow.push null
          tileRow.push null

    @mapTileGrid = tileRows
    @mapSpriteGrid = spriteRows


module.exports = MapSpike
roomTypes = []

roomTypes[0] = [
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
        
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,null,0x00,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,null,0x00,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,null,0x00,0x00, null,null,null,null, null,null,null,null, null,null,null,null ]
        
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,0x00,null ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,0x00,null ]
  [ 0x00,0x00,null,null, null,0x00,null,null, null,null,null,null, null,null,0x00,null ]
  [ 0x00,null,null,null, null,0x00,null,null, null,null,null,null, 0x00,null,0x00,null ]
        
  [ 0x00,null,0x00,null, null,0x00,null,null, null,null,null,null, null,null,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
]

roomTypes[1] = [
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]

  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]

  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]

  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
]


roomTypes[2] = [
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]

  [ null,null,null,null, null,null,null,null, null,null,0x00,null, 0x00,null,0x00,0x00 ]
  [ null,null,0x00,null, null,0x00,null,null, null,null,0x00,null, 0x00,null,0x00,0x00 ]
  [ null,null,0x00,null, null,0x00,0x00,0x00, null,null,0x00,0x00, 0x00,null,0x00,0x00 ]
  [ 0x00,null,0x00,0x00, 0x00,null,null,null, null,null,null,null, null,null,0x00,0x00 ]

  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,0x00,0x00 ]
  [ null,null,null,null, null,null,null,null, 0x00,0x00,0x00,null, null,null,0x00,0x00 ]
  [ null,0x00,null,null, null,0x00,null,null, null,0x00,0x00,null, null,null,0x00,0x00 ]
  [ null,null,null,null, null,0x00,null,null, null,null,null,null, 0x00,null,0x00,0x00 ]

  [ null,null,0x00,null, null,0x00,null,null, null,null,null,null, null,null,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
]

areaA = [
  [ 0, 1, 2]
]
