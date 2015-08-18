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

StateHistory = require '../utils/state_history'
Debug = require '../utils/debug'

MapDatabase = require './map/map_database'

# TestLevel = require './test_level'
ZoomerLevel = require './zoomer_level'

class MainSpike
  constructor: ({@componentInspector}) ->
    @level = ZoomerLevel

    @defaultInput = Immutable.fromJS
      controllers:
        player1: {}
        player2: {}
        debug1: {}
        admin: {}
      dt: 0
      static:
        mapDatabase: @level.mapDatabase()

    @_setupControllers()

    @gameMachine = new EcsMachine(systems: @level.gameSystems())

    @estore = new EntityStore()
    @level.populateInitialEntities(@estore)

    @stateHistory = new StateHistory()
    @captureTimeWalkSnapShot(@estore)


  graphicsToPreload: ->
    @level.graphicsToPreload()

  soundsToPreload: ->
    @level.soundsToPreload()

  setupStage: (stage, width, height) ->
    @viewMachine = new ViewMachine
      stage: stage
      mapDatabase: @level.mapDatabase()
      spriteConfigs: @level.spriteConfigs()
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

    @debugController = new KeyboardController
      bindings:
        "h": 'moveLeft'
        "j": 'moveDown'
        "k": 'moveUp'
        "l": 'moveRight'
        "c": 'toggleCrawl'
        "b": 'toggleCrawlDir'
        "f": 'mod1'

    @useGamepad = false
    @p1Controller = @keyboardController



  update: (dt) ->
    ac = @adminController.update()
    @handleAdminControls(ac) if ac?

    p1ControllerInput = Immutable.fromJS(
      @p1Controller.update()
    )
    debugControllerInput = Immutable.fromJS(
      @debugController.update()
    )

    input = @defaultInput
      .set('dt', dt)
      .setIn(['controllers','player1'], p1ControllerInput)
      .setIn(['controllers','debug1'], debugControllerInput)
    
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



module.exports = MainSpike
