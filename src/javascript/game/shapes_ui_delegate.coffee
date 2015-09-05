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
# ZoomerLevel = require './zoomer_level'
ShapesLevel = require './shapes_level'

class ShapesUiDelegate
  constructor: ({@componentInspector}) ->
    # @titleLevel = MainTitleLevel
    # @level = ZoomerLevel
    @level = ShapesLevel

    @defaultInput = Immutable.fromJS
      controllers:
        player1: {}
        player2: {}
        debug1: {}
      dt: 0
      static: {}
        # mapDatabase: @level.mapDatabase()

    @_setupControllers()

  # Return an Array of image / spritemap filenames:
  graphicsToPreload: ->
    @level.graphicsToPreload()

  # Return an JS Object with sounds IDs as keys and sound files as values:
  soundsToPreload: ->
    @level.soundsToPreload()

  setupStage: (stage, width, height,zoom) ->
    # @_activateTitleScreen()
    @_activateMainGame()

    @viewMachine = new ViewMachine
      stage: stage
      zoomScale: zoom
      aspectScale:
        x: 1.0
        y: 1.0
      # mapDatabase: @level.mapDatabase()
      # spriteConfigs: @level.spriteConfigs()
      componentInspector: @componentInspector

  _activateMainGame: ->
    @gameMachine = new EcsMachine
      systems: @level.gameSystems()

    @estore = new EntityStore()
    @level.populateInitialEntities(@estore)

    @stateHistory = new StateHistory()
    @captureTimeWalkSnapShot(@estore)

  #
  # _activateTitleScreen: ->
  #   @gameMachine = new EcsMachine(systems: @titleLevel.gameSystems())
  #   @estore = new EntityStore()
  #   @titleLevel.populateInitialEntities(@estore)
  #   @stateHistory = new StateHistory()
  #   @captureTimeWalkSnapShot(@estore)


  _setupControllers: ->
    # @keyboardController = new KeyboardController
    #   bindings:
    #     "right": 'right'
    #     "left": 'left'
    #     "up": 'up'
    #     "down": 'down'
    #     "a": 'action2'
    #     "s": 'action1'
    #     "enter": 'start'
    #   mutually_exclusive_actions: [
    #     [ 'right', 'left' ]
    #     [ 'up', 'down' ]
    #   ]
        
    # @gamepadController = new GamepadController
    #   "DPAD_RIGHT": 'right'
    #   "DPAD_LEFT": 'left'
    #   "DPAD_UP": 'up'
    #   "DPAD_DOWN": 'down'
    #   "FACE_1": 'action2'
    #   "FACE_3": 'action1'


    @adminController = new KeyboardController
      bindings:
        # "b": 'toggle_bgm'
        # "g": 'toggle_gamepad'
        "d": 'toggle_bounding_box'
        "p": 'toggle_pause'
        "<": 'time_walk_back'
        ">": 'time_walk_forward'
        ",": 'time_scroll_back'
        ".": 'time_scroll_forward'
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

    # @useGamepad = false
    # @p1Controller = @keyboardController



  update: (dt) ->
    ac = @adminController.update()
    @handleAdminControls(ac) if ac?

    # p1ControllerInput = Immutable.fromJS(
    #   @p1Controller.update()
    # )
    debugControllerInput = Immutable.fromJS(
      @debugController.update()
    )

    input = @defaultInput
      .set('dt', dt)
      # .setIn(['controllers','player1'], p1ControllerInput)
      .setIn(['controllers','debug1'], debugControllerInput)
    
    events = null
    if @paused
      if @step_forward
        @step_forward = false

        input = input.set('dt', 17)
        [@estore,events] = @gameMachine.update(@estore,input)
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
      [@estore,events] = @gameMachine.update(@estore, input)
      @captureTimeWalkSnapShot(@estore)

    @viewMachine.update(@estore.readOnly())

    if events? and events.size > 0
      0
      # if e = events.find((e) -> e.get('name') == 'StartNewGame')
      #   console.log "NEW GAME!",e.toJS()
      #   @_activateMainGame()
      # if e = events.find((e) -> e.get('name') == 'ContinueGame')
      #   console.log "CONTINUE GAME!",e.toJS()
      #   @_activateMainGame()
      # if e = events.find((e) -> e.get('name') == 'Killed')
      #   console.log "KILLED!",e.toJS()
      #   @_activateTitleScreen()

      # else
      #   console.log events.toJS()



  captureTimeWalkSnapShot: (estore) ->
    @stateHistory.addState estore.takeSnapshot()
    
  handleAdminControls: (ac) ->
    # if ac.toggle_gamepad
    #   @useGamepad = !@useGamepad
    #   if @useGamepad
    #     @p1Controller = @gamepadController
    #   else
    #     @p1Controller = @keyboardController

    # if ac.toggle_bgm
    #   if @bgmId?
    #     @estore.destroyEntity @bgmId
    #     @bgmId = null
    #   else
    #     @bgmId = @estore.createEntity [
    #       C.Sound.merge soundId: 'brinstar', timeLimit: 116000, volume: 0.3
    #     ]

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



module.exports = ShapesUiDelegate
