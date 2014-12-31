PIXI = require 'pixi.js'
_ = require 'lodash'

Mousetrap = require '../vendor/mousetrap_wrapper'
KeyboardController = require '../input/keyboard_controller'
# GamepadController = require('../input/gamepad_controller')

EntityStore = require '../ecs/entity_store'
Systems = require './systems'

Samus = require './entity/samus'


Systems.register 'controller_action', class GestureAction
  run: (estore,dt,input) ->
    for samus in estore.getComponentsOfType('samus')
      controller = estore.getComponent(samus.eid, 'controller')
      ctrl = controller.states
      
      if ctrl.up
        samus.aim = 'up'
      else
        samus.aim = 'straight'
    
      # if ctrl.left or ctrl.right
      #   console.log "L/R: #{ctrl.left} #{ctrl.right}"
      if ctrl.left
        samus.direction = 'left'
      else if ctrl.right
        samus.direction = 'right'

      switch samus.motion
        when 'standing'
          if ctrl.jump
            samus.action = 'jump'
          else if ctrl.right or ctrl.left
            samus.action = 'run'

        when 'running'
          if ctrl.jump
            samus.action = 'jump'
          else if ctrl.right or ctrl.left
            # If we don't re-iterate the run action, mid-run direction changes will not register
            samus.action = 'run'
          else
            samus.action = 'stand'

        when 'falling'
          if ctrl.left or ctrl.right
            samus.action = 'drift'

        when 'jumping'
          if !ctrl.jump
            samus.action = 'fall'

          if ctrl.left or ctrl.right
            samus.action = 'drift'

      # if samus.action?
      #   console.log "action: #{samus.action}"

Systems.register 'action_velocity', class ActionVelocity
  run: (estore,dt,input) ->
    # run | drift | stand | jump | fall
    for samus in estore.getComponentsOfType('samus')
      velocity = estore.getComponent(samus.eid, 'velocity')

      switch samus.action
        when 'run'
          if samus.direction == 'right'
            velocity.x = samus.runSpeed
          else
            velocity.x = -samus.runSpeed

        when 'drift'
          if samus.direction == 'right'
            velocity.x = samus.floatSpeed
          else
            velocity.x = -samus.floatSpeed

        when 'stand'
          velocity.x = 0

        when 'jump'
          velocity.y = -samus.jumpSpeed


        when 'fall'
          velocity.y = 0

      samus.action = null

      # TODO: Gravity system?
      # TODO: always apply? or just when airborn?
      # velocity.y += 100/1000 * dt
      max = 200/1000
      velocity.y += max/10
      velocity.y = max if velocity.y > max
      # console.log "v #{velocity.x} #{velocity.y}"
    

Systems.register 'velocity_position', class GestureAction
  run: (estore,dt,input) ->
    for velocity in estore.getComponentsOfType('velocity')
      if position = estore.getComponent(velocity.eid, 'position')
        dx = velocity.x * dt
        dy = velocity.y * dt

        position.x += dx
        position.y += dy

        if position.y > 240
          position.y = 240
          velocity.y = 0
        # console.log velocity.y


    # translate velocity into position
    # resolve terrain collisions
    # --> updated velocity and position
    
Systems.register 'update_motion', class UpdateMotion
  run: (estore,dt,input) ->
    for samus in estore.getComponentsOfType('samus')
      velocity = estore.getComponent(samus.eid, 'velocity')

      m = samus.motion
      samus.motion = if velocity.y < 0
        'jumping'
      else if velocity.y > 0
        'falling'
      else if velocity.x == 0
        'standing'
      else
        'running'

      if samus.motion != m
        console.log "Motion updated: #{samus.motion}"



class CollisionSpike
  constructor: ->

  graphicsToPreload: ->
    assets = Samus.assets
    assets

  setupStage: (@stage, width, height) ->
    @layers = @setupLayers()

    @estore = new EntityStore()

    @samusId = @estore.createEntity Samus.factory.createComponents('samus')

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
      'update_motion'
      'controller'
      'controller_action'
      'action_velocity'
      'velocity_position'
      # 'samus_motion'
      'samus_animation'
      # 'movement'
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
    

module.exports = CollisionSpike

