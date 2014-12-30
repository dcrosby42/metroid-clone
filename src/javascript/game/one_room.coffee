PIXI = require 'pixi.js'
_ = require 'lodash'
# $ = require 'jquery'

Mousetrap = require '../vendor/mousetrap_wrapper'
KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')

EntityStore    = require '../ecs/entity_store'
SystemRegistry = require '../ecs/system_registry'
Systems = require './systems'

Samus = require './entity/samus'


# TODO: Add Skree 
# TODO: aim-up
# TODO: shooting sprites
# TODO: bullets
# TODO: Sounds: running, shooting
# TODO: map 
# TODO: map+motion collision detection
# TODO: jumping
# TODO: Add Skree 
class OneRoom
  constructor: ->

  graphicsToPreload: ->
    assets = Samus.assets

    assets = assets.concat [
      "images/room0_blank.png"
    ]
    assets

  setupStage: (@stage, width, height) ->
    @layers = @setupLayers()

    @sampleMapBg = PIXI.Sprite.fromFrame("images/room0_blank.png")
    @layers.map.addChild @sampleMapBg

    @estore = new EntityStore()

    @samusId = @createSamus(@estore)

    @setupSpriteConfigs()

    @setupSystems()

    @setupInput()
    
    @timeDilation = 1

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
      "right": 'right'
      "left": 'left'
      "up": 'up'
      "down": 'down'
      "a": 'jump'
      "s": 'shoot'

    @adminController = new KeyboardController
      "g": 'toggle_gamepad'

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

    @spriteLookupTable = {}

  setupSystems: ->
    @systemsRunner = Systems.sequence [
      'controller'
      'samus_motion'
      'samus_animation'
      'movement'
      ['sprite_sync',
        spriteConfigs: @spriteConfigs
        spriteLookupTable: @spriteLookupTable
        layers: @layers ]
    ]

  update: (dt) ->
    @handleAdminControls()
      
    @input.controllers.player1 = @p1Controller.update()
    # @input.controllers.player2 = @p2Controller.update()

    @systemsRunner.run @estore, dt*@timeDilation, @input

  handleAdminControls: ->
    ac = @adminController.update()
    if ac and ac.toggle_gamepad
      @useGamepad = !@useGamepad
      if @useGamepad
        @p1Controller = @gamepadController
      else
        @p1Controller = @keyboardController
    
  createSamus: (estore) ->
    estore.createEntity Samus.factory.createComponents('samus')

module.exports = OneRoom

