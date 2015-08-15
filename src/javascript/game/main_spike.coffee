PIXI = require 'pixi.js'
_ = require 'lodash'
Immutable = require 'immutable'

KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')

EntityStore = require '../ecs/entity_store'


EcsMachine = require '../ecs/ecs_machine'
ViewMachine = require './view_machine'


CommonSystems = require './systems'
SamusSystems =  require './entity/samus/systems'
EnemiesSystems =  require './entity/enemies/systems'


C = require './entity/components'

Samus = require './entity/samus'
Enemies = require './entity/enemies'
General = require './entity/general'

MapData = require './map/map_data'

StateHistory = require '../utils/state_history'
Debug = require '../utils/debug'

class MainSpike
  constructor: ({@componentInspector}) ->
    @maps = Immutable.Map(
      areaA: @setupMap( MapData.areas.a )
      areaB: @setupMap( MapData.areas.b )
      areaC: @setupMap( MapData.areas.c )
    )

    @defaultInput = Immutable.fromJS
      controllers:
        player1: {}
        player2: {}
        admin: {}
      dt: 0
      static:
        maps: @maps

    @_setupControllers()

    # Setup game machine:
    @gameMachine = new EcsMachine(systems: @_createSystems())
    @estore = new EntityStore()
    @estore.createEntity [
      Immutable.fromJS(type: "map", name: "areaA")
    ]
    @estore.createEntity Samus.factory.createComponents('samus')
    for x in [150, 200, 250, 300, 350]
      @estore.createEntity Enemies.factory.createComponents('basicSkree', x:x, y: 32)


    @stateHistory = new StateHistory()


  graphicsToPreload: ->
    assets = [
      "images/brinstar.json"
    ]
    assets = assets.concat(Samus.assets)
    assets = assets.concat(Enemies.assets)
    assets = assets.concat(General.assets)

    assets


  soundsToPreload: ->
    songs = ["brinstar"]
    effects = [
      "enemy_die1"
      "health"
      "step2"
      "jump"
      "samus_hurt"
      "samus_die"
      "short_beam"
    ]
    assets = {}
    for song in songs
      assets[song] = "sounds/music/#{song}.mp3"
    for effect in effects
      assets[effect] = "sounds/fx/#{effect}.wav"
    assets


  setupStage: (stage, width, height) ->
    @viewMachine = new ViewMachine
      stage: stage
      maps: @maps
      spriteConfigs: @_getSpriteConfigs()
      componentInspector: @componentInspector


  _setupControllers: ->
    @keyboardController = new KeyboardController
      bindings:
        "right": 'right'
        "left": 'left'
        "up": 'up'
        "down": 'down'
        "a": 'action2'
        "s": 'action1'
      mutually_exclusive_actions: [
        [ 'right', 'left' ]
        [ 'up', 'down' ]
      ]
        
    @gamepadController = new GamepadController
      "DPAD_RIGHT": 'right'
      "DPAD_LEFT": 'left'
      "DPAD_UP": 'up'
      "DPAD_DOWN": 'down'
      "FACE_1": 'action2'
      "FACE_3": 'action1'


    @adminController = new KeyboardController
      bindings:
        "g": 'toggle_gamepad'
        "b": 'toggle_bgm'
        "p": 'toggle_pause'
        "d": 'toggle_bounding_box'
        "m": 'cycle_admin_mover'
        "<": 'time_walk_back'
        ">": 'time_walk_forward'
        ",": 'time_scroll_back'
        ".": 'time_scroll_forward'
        "h": 'left'
        "j": 'down'
        "k": 'up'
        "l": 'right'
        "space": 'step_forward'

    @useGamepad = false
    @p1Controller = @keyboardController

  _getSpriteConfigs: ->
    spriteConfigs = {}
    _.merge spriteConfigs, Samus.sprites
    _.merge spriteConfigs, Enemies.sprites
    _.merge spriteConfigs, General.sprites
    spriteConfigs

  _createSystems: ->
    [
      CommonSystems.timer_system
      CommonSystems.death_timer_system
      CommonSystems.visual_timer_system
      CommonSystems.sound_system
      SamusSystems.samus_motion
      CommonSystems.controller_system
      SamusSystems.samus_controller_action
      SamusSystems.short_beam_system
      SamusSystems.samus_action_velocity
      CommonSystems.samus_hit_system
      CommonSystems.samus_damage_system
      SamusSystems.samus_action_sounds
      CommonSystems.gravity_system
      CommonSystems.map_physics_system
      CommonSystems.map_ghost_system
      CommonSystems.bullet_enemy_system
      CommonSystems.bullet_system
      CommonSystems.enemy_hit_system
      EnemiesSystems.skree_action
      SamusSystems.samus_animation
    ]

  update: (dt) ->
    ac = @adminController.update()
    @handleAdminControls(ac) if ac?

    p1ControllerInput = Immutable.fromJS(
      @p1Controller.update()
    )

    input = @defaultInput
      .set('dt', dt)
      .setIn(['controllers','player1'], p1ControllerInput)
    
    if @paused
      if @step_forward
        @step_forward = false

        input = input.set('dt', 17)
        @gameMachine.update(@estore,input)
        @captureTimeWalkSnapShot(@estore)

      if @time_walk_back or @time_scroll_back
        @time_walk_back = false
        if snapshot = @stateHistory.stepBack()
          @estore.restoreSnapshot(snapshot)
        else
          console.log "(null snapshot, not restoring)"


      if @time_walk_forward or @time_scroll_forward
        @time_walk_forward = false
        if snapshot = @stateHistory.stepForward()
          @estore.restoreSnapshot(snapshot)
        else
          console.log "(null snapshot, not restoring)"

    else
      @gameMachine.update(@estore, input)
      @captureTimeWalkSnapShot(@estore)

    @viewMachine.update(@estore.readOnly())


  captureTimeWalkSnapShot: (estore) ->
    @stateHistory.addState estore.takeSnapshot()
    
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
          C.Sound.merge soundId: 'brinstar', timeLimit: 116000, volume: 0.3
        ]

    if ac.toggle_pause
      if @paused
        @paused = false
      else
        @paused = true

    if @paused
      if ac.step_forward
        @step_forward = true

      else if ac.time_walk_back
        @time_walk_back = true

      else if ac.time_walk_forward
        @time_walk_forward = true

      else if ac.time_scroll_back
        @time_scroll_forward = off
        @time_scroll_back = true

      else if ac.time_scroll_forward
        @time_scroll_back = off
        @time_scroll_forward = true

      else
        @time_scroll_back = off
        @time_scroll_forward = off

    if ac.toggle_bounding_box
      @viewMachine.drawHitBoxes = !@viewMachine.drawHitBoxes


  setupMap: (map) ->
    mapTileHeight = MapData.info.tileHeight
    mapTileWidth = MapData.info.tileWidth
    roomWidth = MapData.info.screenWidthInTiles
    roomHeight = MapData.info.screenHeightInTiles

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


module.exports = MainSpike
