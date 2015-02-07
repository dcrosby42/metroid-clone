PIXI = require 'pixi.js'
_ = require 'lodash'

Mousetrap = require '../vendor/mousetrap_wrapper'
KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')

EntityStore = require '../ecs/entity_store'

SystemRegistry = require '../ecs/system_registry'
CommonSystems = require './systems'

Common = require './entity/components'

class HitBoxVisual
  constructor: ({@color})->
    @ctype = 'hit_box_visual'

class Tags
  constructor: (@tags) ->
    @ctype = 'tags'

ArrayToCacheBinding = require '../pixi_ext/array_to_cache_binding'
AnchoredBox = require '../utils/anchored_box'
class HitBoxVisualSyncSystem
  constructor: ({@cache,@layer}) ->

  run: (estore,dt,input) ->
    hitBoxVisuals = estore.getComponentsOfType('hit_box_visual')
    ArrayToCacheBinding.update
      source: hitBoxVisuals
      cache: @cache
      identKey: 'eid'
      addFn: (hitBoxVisual) =>
        console.log "hitBoxVisual sync",hitBoxVisual
        hitBox = estore.getComponent(hitBoxVisual.eid, 'hit_box')
        abox = new AnchoredBox(hitBox)
        abox.setXY 0,0

        thickness = 0.5
        color = hitBoxVisual.color || 0xFFFFFF
        pinColor = 0xFF0000
        
        gfx = new PIXI.Graphics()

        gfx.lineStyle thickness, color
        # gfx.drawRect -32,-16,64,32
        gfx.drawRect abox.left, abox.top, abox.width, abox.height

        gfx.lineStyle thickness, pinColor
        gfx.moveTo(0,4)
        gfx.lineTo(0,0)
        gfx.lineTo(4,0)

        @layer.addChild gfx
        gfx

      removeFn: (gfx) =>
        gfx.parent.removeChild gfx

      syncFn: (hitBoxVisual,gfx) =>
        hitBox = estore.getComponent(hitBoxVisual.eid, 'hit_box')
        gfx.position.set hitBox.x, hitBox.y

class BoxMoverSystem
  run: (estore,dt,input) ->
    xStep = 4
    yStep = 4
    for hitBox in estore.getComponentsOfType('hit_box')
      if controller = estore.getComponent(hitBox.eid, 'controller')
        ctrl = controller.states
        if ctrl.up
          hitBox.y -= yStep
        if ctrl.down
          hitBox.y += yStep
        if ctrl.left
          hitBox.x -= xStep
        if ctrl.right
          hitBox.x += xStep


class BoxDrawSpike
  constructor: ->

  graphicsToPreload: ->
    []

  soundsToPreload: ->
    {}

  setupStage: (@stage, width, height) ->
    @estore = new EntityStore()

    @layers = @setupLayers()
    @stage.addChild @layers.scaler


    eid = @estore.createEntity [
      new Tags(['one'])
      new Common.Controller(inputName: 'player1')
      new Common.HitBox
        x: 0
        y: 0
        width: 32
        height: 16
        anchorX: 0.5
        anchorY: 0.5
      new HitBoxVisual
        color: 0x0099FF
    ]

    @setupInput()

    @setupSystems()

    window.me = @
    window.estore = @estore
    window.stage = @stage

  setupLayers: ->
    scaler = new PIXI.DisplayObjectContainer()
    scaler.scale.set(2.5,2) # double size, and stretch the actual nintendo 256 px to look like 320
    base = new PIXI.DisplayObjectContainer()

    scaler.addChild base
    base.addChild

    return {
      scaler: scaler
      base: base
    }

  setupInput: ->
    @input =
      controllers:
        player1: {}
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
        "b": 'toggle_draw_boxes'

  setupSystems: ->
    Systems = new SystemRegistry()
    Systems.register CommonSystems
    Systems.register 'hit_box_visual_sync_system', HitBoxVisualSyncSystem
    Systems.register 'box_mover_system', BoxMoverSystem

    @systemsRunner = Systems.sequence [
      # 'death_timer_system'
      # 'visual_timer_system'
    
      'controller_system'

      'box_mover_system'
   
      # 'gravity_system'

      # 
      # 'output' systems mutate world state (graphics, sounds, browser etc)
      #
      # ['sprite_sync_system',
      #   spriteConfigs: @spriteConfigs
      #   spriteLookupTable: {}
      #   layers: @layers ]
      ['hit_box_visual_sync_system'
        cache: {}
        layer: @layers.base ]
    ]


  update: (dt) ->
    @handleAdminControls()
    @input.controllers.player1 = @keyboardController.update()

    @systemsRunner.run @estore, dt, @input

  handleAdminControls: ->
    ac = @adminController.update()
    # if ac
    #   if ac.toggle_gamepad
    #     @useGamepad = !@useGamepad
    #     if @useGamepad
    #       @p1Controller = @gamepadController
    #     else
    #       @p1Controller = @keyboardController

module.exports = BoxDrawSpike
