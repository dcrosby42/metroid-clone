Immutable = require 'immutable'

Transforms = require './transforms'

KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')
ControllerEventMux = require('../input/controller_event_mux')

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

ImmRingBuffer = require '../utils/imm_ring_buffer'
Debug = require '../utils/debug'

WorldMap = require './map/world_map'

# TestLevel = require './test_level'
# ZoomerLevel = require './zoomer_level'
RoomsLevel = require './rooms_level'
MainTitleLevel = require './main_title_level'

# GameControlMappings = Immutable.Map
#   player1: 'p1Keyboard'
#   debug1: 'debug'

ImmRingBuffer = require '../utils/imm_ring_buffer'


class MetroidCloneDelegate
  constructor: ({componentInspector}) ->
    @titleLevel = MainTitleLevel
    # @level = ZoomerLevel
    @level = RoomsLevel

    @playingTheGameMachine = new EcsMachine(systems: @level.gameSystems())
    @titleMachine = new EcsMachine(systems: @titleLevel.gameSystems())

    # @estore = new EntityStore()

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


    @adminState = Immutable.fromJS
      controller:{}
      paused: false
      # stateHistory: ImmRingBuffer.create(5*60)
    @stateHistory = ImmRingBuffer.create(5*60)

    uiState = UIState.create
      stage: stage
      zoomScale: zoom
      aspectScale:
        x: 1.25
        y: 1

    uiConfig = UIConfig.create
      worldMap: WorldMap.getDefaultWorldMap()
      spriteConfigs: @level.spriteConfigs()
      
    viewSystems = @_createViewSystems()

    @viewMachine = new ViewMachine
      systems: viewSystems
      uiConfig: uiConfig
      uiState: uiState

    # Enter the main title screen
    @gameMachine = @titleMachine
    @gameState = @_getInitialState(@titleLevel)

  _getInitialState: (level) ->
    es = new EntityStore()
    level.populateInitialEntities(es)
    return es.takeSnapshot()

  _setupControllers: ->
    keyboardController = new KeyboardController
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
        
    gamepadController = new GamepadController
      "DPAD_RIGHT": 'right'
      "DPAD_LEFT": 'left'
      "DPAD_UP": 'up'
      "DPAD_DOWN": 'down'
      "FACE_1": 'action2'
      "FACE_3": 'action1'


    adminController = new KeyboardController
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

    debugController = new KeyboardController
      bindings:
        "h": 'moveLeft'
        "j": 'moveDown'
        "k": 'moveUp'
        "l": 'moveRight'
        "c": 'toggleCrawl'
        "b": 'toggleCrawlDir'
        "f": 'mod1'

    @controllerEventMux = new ControllerEventMux(
      admin: adminController
      debug: debugController
      p1Keyboard: keyboardController
      p1Gamepad: gamepadController
    )

  # _mapControllerEvents: (events, mappings) ->
  #   mappings.reduce (controllers, src,dest) ->
  #     controllers.set dest, events.get(src)
  #   , Immutable.Map()



  update: (dt) ->
    controllerEvents = @controllerEventMux.next()

    @adminState = Transforms.updateAdmin(@adminState, controllerEvents.get('admin'))

    [@stateHistory, action] = Transforms.selectAction(@stateHistory,dt,controllerEvents,@adminState)

    [@gameState,events] = switch action.get('type')
      when "useState"
        [action.get('gameState'), null]
      when "computeState"
        input = @defaultInput.merge(action.get('input'))
        [gameState1,events] = @gameMachine.update2(@gameState,input)
        @stateHistory = ImmRingBuffer.add(@stateHistory, gameState1)
        [gameState1, events]
      when "nothing"
        [@gameState, null]
      else
        throw new Error("WTF Transforms.selectAction returned #{action.toJS()}")

    # # ------------------------------------------------------------------------
    # adminState = @adminState # -->
    # stateHistory = @stateHistory
    #
    # gameState0 = @gameState # -->
    # gameMachine = @gameMachine # -->
    # gameControlMappings = GameControlMappings # -->
    # defaultInput = @defaultInput # -->
    # # controllerEvents -->
    # # ------------------------------------------------------------------------
    #
    # gameState1 = null
    # events = null
    # if adminState.get('paused')
    #   if adminState.get('replay_forward')
    #     stateHistory = ImmRingBuffer.forward(stateHistory)
    #     gameState1 = ImmRingBuffer.read(stateHistory)
    #
    #   else if adminState.get('replay_back')
    #     stateHistory = ImmRingBuffer.backward(stateHistory)
    #     gameState1 = ImmRingBuffer.read(stateHistory)
    #
    #   else if adminState.get('step_forward')
    #     # paused, step forward one nominal time slice. 17 =~ 16.666
    #     dt = 17
    #
    #   else
    #     # paused. no change.
    #     gameState1 = ImmRingBuffer.read(stateHistory)
    #
    # if !gameState1
    #   gameInput = defaultInput
    #     .set('dt', dt)
    #     .set('controllers', @_mapControllerEvents(controllerEvents,gameControlMappings))
    #
    #   [gameState1,events] = gameMachine.update2(gameState0,gameInput)
    #
    #   stateHistory = ImmRingBuffer.add(stateHistory, gameState1)
    #
    # # ------------------------------------------------------------------------
    # @stateHistory = stateHistory # <---
    # @gameState = gameState1 # <-- 
    # # events # <--
    # # ------------------------------------------------------------------------

    # (maybe) Switch levels based on game events
    switchLevel = (level,machine) =>
      @gameState = @_getInitialState(level)
      
      @gameMachine = machine
      @stateHistory = ImmRingBuffer.add(ImmRingBuffer.clear(@stateHistory), @gameState)
      # @adminState.update('stateHistory', (h) ->
      #   ImmRingBuffer.add(ImmRingBuffer.clear(h), @gameState))

    if events? and events.size > 0
      if e = events.find((e) -> e.get('name') == 'StartNewGame')
        switchLevel @level, @playingTheGameMachine
      else if e = events.find((e) -> e.get('name') == 'ContinueGame')
        switchLevel @level, @playingTheGameMachine
      else if e = events.find((e) -> e.get('name') == 'Killed')
        switchLevel @titleLevel, @titleMachine


    # Update the view:
    @viewMachine.update2 @gameState

    # Update the component inspector:
    @componentInspectorMachine.update2 @gameState

    # TODO -- handle admin control 'toggle_bounding_box' to :
    #   @viewMachine.uiState.drawHitBoxes = !@viewMachine.uiState.drawHitBoxes

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
