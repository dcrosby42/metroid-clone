PIXI = require 'pixi.js'
_ = require 'lodash'

Mousetrap = require '../vendor/mousetrap_wrapper'
KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')

EntityStore = require '../ecs/entity_store'

SystemRegistry = require '../ecs/system_registry'
CommonSystems = require './systems'

Common = require './entity/components'

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
      new Common.Controller(inputName: 'player1')
      new Common.HitBox
        x: 0
        y: 0
        width: 32
        height: 16
        anchorX: 0.5
        anchorY: 0.5
      new Common.HitBoxVisual
        color: 0x0099FF
    ]

    @setupInput()
    @setupSystems()

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

    @keyboardController = new KeyboardController
      bindings:
        "right": 'right'
        "left": 'left'
        "up": 'up'
        "down": 'down'
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
    Systems.register 'box_mover_system', BoxMoverSystem

    @systemsRunner = Systems.sequence [
      'controller_system'
      'box_mover_system'

      # OUTPUT:
      ['hit_box_visual_sync_system'
        cache: {}
        layer: @layers.base ]
    ]


  update: (dt) ->
    @input.controllers.player1 = @keyboardController.update()

    @systemsRunner.run @estore, dt, @input

module.exports = BoxDrawSpike
