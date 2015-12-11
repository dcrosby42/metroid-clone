Immutable = require 'immutable'

KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')
ControllerEventMux = require('../input/controller_event_mux')
PressedReleased = require('../utils/pressed_released')

EntityStore = require '../ecs/entity_store'
EcsMachine = require '../ecs/ecs_machine'

ViewMachine = require '../view/view_machine'
ViewSystems = require '../view/systems'
UIState = require '../view/ui_state'
UIConfig = require '../view/ui_config'

ComponentInspectorMachine = require '../view/component_inspector_machine'
CommonSystems = require './systems'
SamusSystems =  require './entity/samus/systems'
EnemiesSystems =  require './entity/enemies/systems'

C = require './entity/components'

Samus = require './entity/samus'
Enemies = require './entity/enemies'
General = require './entity/general'

StateHistory = require '../utils/state_history'
Debug = require '../utils/debug'

# MapDatabase = require './map/map_database'
WorldMap = require './map/world_map'

# TestLevel = require './test_level'
# ZoomerLevel = require './zoomer_level'
RoomsLevel = require './rooms_level'
MainTitleLevel = require './main_title_level'

GameControlMappings = Immutable.Map
  player1: 'p1Keyboard'
  debug1: 'p1Gamepad'


class MetroidCloneDelegate
  constructor: ({componentInspector}) ->
    @titleLevel = MainTitleLevel
    # @level = ZoomerLevel
    @level = RoomsLevel

    @defaultInput = Immutable.fromJS
      controllers:
        player1: {}
        player2: {}
        debug1: {}
        admin: {}
      dt: 0
      static:
        worldMap: WorldMap.getDefaultWorldMap()
        mapDatabase: @level.mapDatabase()

    @_setupControllers()

    @componentInspectorMachine = new ComponentInspectorMachine(componentInspector: componentInspector)

  graphicsToPreload: ->
    assets = @level.graphicsToPreload()
    assets = assets.concat(@titleLevel.graphicsToPreload())
    assets

  soundsToPreload: ->
    sounds = @level.soundsToPreload()
    sounds = _.merge(sounds, @titleLevel.soundsToPreload())
    sounds

  setupStage: (stage, width, height,zoom) ->
    # @titleGameMachine = new EcsMachine(systems: @titleLevel.gameSystems())
    # @mainGameMachine = new EcsMachine(systems: @level.gameSystems())

    @_activateTitleScreen()
    # @_activateMainGame()

    @adminState = Immutable.fromJS(controller:{})

    uiState = UIState.create
      stage: stage
      zoomScale: zoom
      aspectScale:
        x: 1.25
        y: 1
    window.uiState = uiState

    uiConfig = UIConfig.create
      worldMap: WorldMap.getDefaultWorldMap()
      spriteConfigs: @level.spriteConfigs()
      # mapDatabase: @level.mapDatabase()
    window.uiConfig = uiConfig
      
    viewSystems = @_createViewSystems()

    @viewMachine = new ViewMachine
      systems: viewSystems
      uiConfig: uiConfig
      uiState: uiState

  _activateMainGame: ->
    @gameMachine = new EcsMachine(systems: @level.gameSystems())
    @estore = new EntityStore()
    @level.populateInitialEntities(@estore)
    @stateHistory = new StateHistory()
    @captureTimeWalkSnapShot(@estore)

  _activateTitleScreen: ->
    @gameMachine = new EcsMachine(systems: @titleLevel.gameSystems())
    @estore = new EntityStore()
    @titleLevel.populateInitialEntities(@estore)
    @stateHistory = new StateHistory()
    @captureTimeWalkSnapShot(@estore)


  _setupControllers: ->
    @keyboardController = new KeyboardController
      bindings:
        "right": 'right'
        "left": 'left'
        "up": 'up'
        "down": 'down'
        "a": 'action2'
        "s": 'action1'
        "enter": 'start'
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

    # XXX
    @useGamepad = true
    # XXX
    @p1Controller = @keyboardController

    @controllerEventMux = new ControllerEventMux(
      admin: @adminController
      debug: @debugController
      p1Keyboard: @keyboardController
      p1Gamepad: @gamepadController
    )

  _mapControllerEvents: (events, mappings) ->
    mappings.reduce (controllers, src,dest) ->
      controllers.set dest, events.get(src)
    , Immutable.Map()

  _updateAdmin: (state, cevts) ->
    controller = PressedReleased.update(state.get('controller'),cevts)
    state = state.set('controller', controller)

    if controller.get('toggle_pausePressed')
      state = state.update 'paused', (p) -> !p
     
    state = state.set('replay_back',
      controller.get('time_walk_backPressed') or
      controller.get('time_scroll_back')
    ).set('replay_forward',
      controller.get('time_walk_forwardPressed') or
      controller.get('time_scroll_forward')
    ).set('step_forward',
      controller.get('step_forwardPressed')
    )
        
    state


  update: (dt) ->
    controllerEvents = @controllerEventMux.next()

    events = null
    @adminState = @_updateAdmin(@adminState, controllerEvents.get('admin'))
    if @adminState.get('paused')
      if @adminState.get('replay_forward')
        if snapshot = @stateHistory.stepForward()
          @estore.restoreSnapshot(snapshot)
      if @adminState.get('replay_back')
        if snapshot = @stateHistory.stepBack()
          @estore.restoreSnapshot(snapshot)
      if @adminState.get('step_forward')
        input = @defaultInput
          .set('dt', 17)
          .set('controllers', @_mapControllerEvents(controllerEvents,GameControlMappings))
        [@estore,events] = @gameMachine.update(@estore,input)
        @captureTimeWalkSnapShot(@estore)
    else
      input = @defaultInput
        .set('dt', 17)
        .set('controllers', @_mapControllerEvents(controllerEvents,GameControlMappings))
      [@estore,events] = @gameMachine.update(@estore,input)
      @captureTimeWalkSnapShot(@estore)

    if events? and events.size > 0
      if e = events.find((e) -> e.get('name') == 'StartNewGame')
        @_activateMainGame()
      if e = events.find((e) -> e.get('name') == 'ContinueGame')
        @_activateMainGame()
      if e = events.find((e) -> e.get('name') == 'Killed')
        @_activateTitleScreen()

    gameState = @estore.readOnly()

    @viewMachine.update gameState

    @componentInspectorMachine.update gameState




  captureTimeWalkSnapShot: (estore) ->
    @stateHistory.addState estore.takeSnapshot()
    
  handleAdminControls: (ac) ->
    # negate = (x) -> !x
    # updateProp = (prop, fn) -> (s) -> s.update prop, fn
    # negateProp = (prop) -> updateProp(prop, negate)
    # cycleProp
    #
    # {
    #   toggle_gamepad: negateProp('useGamepad')
    #   toggle_bgm: (s) ->
    #     if bgmId = s.get('bgmId')
    #
    #
    #
    # }
    #
    if ac.toggle_gamepad
      @useGamepad = !@useGamepad
      if @useGamepad
        @p1Controller = @gamepadController
      else
        @p1Controller = @keyboardController

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
      # TODO: not beautiful. HitBoxVisualSyncSystem uses this.
      @viewMachine.uiState.drawHitBoxes = !@viewMachine.uiState.drawHitBoxes

  _createViewSystems: ->
    systemDefs = [
      # ViewSystems.map_sync_system
      ViewSystems.animation_sync_system
      ViewSystems.label_sync_system
      ViewSystems.ellipse_sync_system
      ViewSystems.rectangle_sync_system
      ViewSystems.hit_box_visual_sync_system
      # ViewSystems.viewport_target_tracker_system
      ViewSystems.viewport_sync_system
      ViewSystems.sound_sync_system
      ViewSystems.room_sync_system
    ]
    Immutable.List(systemDefs).map (s) -> s.createInstance()


module.exports = MetroidCloneDelegate
