PIXI = require 'pixi.js'
_ = require 'lodash'

Mousetrap = require '../vendor/mousetrap_wrapper'
KeyboardController = require '../input/keyboard_controller'
# GamepadController = require('../input/gamepad_controller')

EntityStore = require '../ecs/entity_store'
Systems = require './systems'

C = require './entity/components'

Systems.register 'viewport-track-samus', class ViewportTrackSamus
  constructor: ({@container,@tileGrid}) ->
    @minX = 0
    @maxX = (@tileGrid[0].length - 16) * 16 # num tiles, less 16 tiles (one room's worth), times tilewidth of 16px
    @minY = 0
    @maxY = (@tileGrid.length - 15) * 16

  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      position = estore.getComponent(samus.eid, 'position')

      viewport =
        x: -@container.x
        y: -@container.y

      if position.x - viewport.x < 7*16
        viewport.x = position.x - 7*16
      else if position.x - viewport.x > 9*16
        viewport.x = position.x - 9*16

      viewport.y = position.y - 7*16

      if viewport.x < @minX
        viewport.x = @minX
      else if viewport.x > @maxX
        viewport.x = @maxX

      if viewport.y < @minY
        viewport.y = @minY
      else if viewport.y > @maxY
        viewport.y = @maxY

      @container.x = -viewport.x
      @container.y = -viewport.y


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

    # @cameraId = @estore.createEntity [
    #   new C.Tags(names: ['camera'])
    #   new C.Position(x:0,y:0)
    # ]

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
        tileGrid: @mapTileGrid
        tileWidth: @mapTileWidth
        tileHeight: @mapTileHeight]
      'samus_animation'

      ['sprite_sync',
        spriteConfigs: @spriteConfigs
        spriteLookupTable: @spriteLookupTable
        layers: @layers ]

      ['viewport-track-samus',
        container: @layers.base
        tileGrid: @mapTileGrid
      ]
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

    @roomWidth = 256
    @roomHeight = 240

    getMapTileSprite = (n) ->
      if n?
        PIXI.Sprite.fromFrame("block-#{n}")
      else
        null

    divRem = (numer,denom) -> [Math.floor(numer/denom), numer % denom]

    map = areaA

    mapRowCount = map.length * 15
    mapColCount = map[0].length * 16

    tileGrid = []
    for r in [0...mapRowCount]
      tileRow = []
      tileGrid.push tileRow
      for c in [0...mapColCount]
        [rr,tr] = divRem(r, 15)
        [rc,tc] = divRem(c, 16)
        roomType = map[rr][rc]
        room = roomTypes[roomType]
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
roomTypes = []

roomTypes[0] = [
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
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
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
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
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
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
