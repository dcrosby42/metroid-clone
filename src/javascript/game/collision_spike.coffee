PIXI = require 'pixi.js'
_ = require 'lodash'

Mousetrap = require '../vendor/mousetrap_wrapper'
KeyboardController = require '../input/keyboard_controller'
# GamepadController = require('../input/gamepad_controller')

EntityStore = require '../ecs/entity_store'
Systems = require './systems'

Samus = require './entity/samus'



Systems.register 'samus_action_velocity', class ActionVelocity
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
      max = 200/1000
      velocity.y += max/10
      velocity.y = max if velocity.y > max
    





tileWidth = 16
samusWidth = 12
halfSamusWidth = samusWidth/2
samusAnchorX = 0.5
samusAnchorY = 1
samusHeight = 32

AnchoredBox = require '../utils/anchored_box'

Systems.register 'map_physics', class MapPhysics
  run: (estore,dt,input) ->
    for velocity in estore.getComponentsOfType('velocity')
      hitBox = estore.getComponent(velocity.eid, 'hit_box')
      position = estore.getComponent(velocity.eid, 'position')
      if hitBox and position
        box = new AnchoredBox(hitBox)
        box.setXY position.x, position.y

        hits =
          left: []
          right: []
          top: []
          bottom: []

        grid = window.mapSpriteGrid

        # Apply & restrict VERTICAL movement
        box.moveY(velocity.y * dt)

        hits.top = tileSearchHorizontal(grid, box.top, box.left, box.right-1)
        if hits.top.length > 0
          s = hits.top[0]
          box.setY(s.y+s.height - box.topOffset)
        else
          hits.bottom = tileSearchHorizontal(grid, box.bottom, box.left, box.right-1)
          if hits.bottom.length > 0
            s = hits.bottom[0]
            box.setY(s.y - box.bottomOffset)
          else

        # Step 2: apply & restrict horizontal movement
        box.moveX(velocity.x * dt)

        hits.left = tileSearchVertical(grid, box.left, box.top, box.bottom-1)
        if hits.left.length > 0
          s = hits.left[0]
          box.setX(s.x+s.width - box.leftOffset)
        else
          hits.right = tileSearchVertical(grid, box.right, box.top, box.bottom-1)
          if hits.right.length > 0
            s = hits.right[0]
            box.setX(s.x - box.rightOffset)
        
        # Update position and hit_box components 
        position.x = box.x
        position.y = box.y
        hitBox.x = box.x # kinda redundant but let's just keep er up2date ok
        hitBox.y = box.y# kinda redundant but let's just keep er up2date ok

        # Update velocity if needed based on running into objects:
        if hits.right.length > 0 or hits.left.length > 0
          velocity.x = 0

        if hits.top.length > 0 or hits.bottom.length > 0
          velocity.y = 0

    

class CollisionSpike
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

    @setupSystems()

    @setupInput()

    @setupMap(@layers['map'])

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
      'samus_motion'
      'controller'
      'samus_controller_action'

      'samus_action_velocity'
      'map_physics'
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
    # for i in [ 0 ]
    #   blockTextures[i] = PIXI.Texture.fromFrame("block-#{i}")
    
    spriteRows = []
    for row,r in roomData
      spriteRow = []
      spriteRows.push spriteRow
      for bnum,c in row
        if bnum?
          sprite = PIXI.Sprite.fromFrame("block-#{bnum}")
          sprite.position.set c*16,r*16
          container.addChild sprite
          spriteRow.push sprite
        else
          spriteRow.push null

    @mapSpriteGrid = spriteRows
    window.mapSpriteGrid = @mapSpriteGrid


module.exports = CollisionSpike

blockTextures = [
  null
]

mapSprites = [
]

roomData = [
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

tileSearchVertical = (grid, x, topY, bottomY) ->
  hits = []
  c = Math.floor(x/16)
  for r in [Math.floor(topY/16)..Math.floor(bottomY/16)]
    row = grid[r]
    if row?
      hit = grid[r][c]
      if hit?
        hits.push hit
  hits

tileSearchHorizontal = (grid, y, leftX, rightX) ->
  hits = []
  r = Math.floor(y/16)
  row = grid[r]
  if row?
    for c in [Math.floor(leftX/16)..Math.floor(rightX/16)]
      hit = grid[r][c]
      if hit?
        hits.push hit
  hits
