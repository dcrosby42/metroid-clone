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

GameStateMachine = require './states/game_state_machine'
TitleState = require './states/title'
AdventureState = require './states/adventure'
PowerupState = require './states/powerup'

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

    @gameStateMachine = new GameStateMachine([
      TitleState
      AdventureState
    ])

    @defaultInput = Immutable.fromJS
      controllers:
        player1: {}
        player2: {}
        debug1: {}
        admin: {}
      dt: 0
      static:
        worldMap: WorldMap.getDefaultWorldMap()
        mapDatabase: RoomsLevel.mapDatabase() # TODO RoomsLevel doesn't seem like the right place

    @controllerEventMux = createControllerEventMux()

    @componentInspectorMachine = new ComponentInspectorMachine(
      componentInspector: componentInspector
    )

    @adminState = Immutable.fromJS
      controller:{}
      paused: false
      drawHitBoxes: false

    @stateHistory = ImmRingBuffer.create(5*60)

  graphicsToPreload: ->
    assets = RoomsLevel.graphicsToPreload()
    assets = assets.concat(MainTitleLevel.graphicsToPreload())
    assets

  soundsToPreload: ->
    sounds = RoomsLevel.soundsToPreload()
    sounds = _.merge(sounds, MainTitleLevel.soundsToPreload())
    sounds

  setupStage: (stage, width, height,zoom) ->
    uiState = UIState.create
      stage: stage
      zoomScale: zoom
      aspectScale:
        x: 1.25
        y: 1

    uiConfig = UIConfig.create
      worldMap: WorldMap.getDefaultWorldMap()
      spriteConfigs: RoomsLevel.spriteConfigs()
      
    viewSystems = createViewSystems()

    @viewMachine = new ViewMachine
      systems: viewSystems
      uiConfig: uiConfig
      uiState: uiState

  update: (dt) ->
    controllerEvents = @controllerEventMux.next()

    @adminState = Transforms.updateAdmin(@adminState, controllerEvents.get('admin'))

    [@stateHistory, action] = Transforms.selectAction(@stateHistory,dt,controllerEvents,@adminState)
    gameState = switch action.get('type')
      when "useState"
        action.get('gameState')

      when "computeState"
        input = @defaultInput.merge(action.get('input'))
        gameState = @gameStateMachine.update(input)
        @stateHistory = ImmRingBuffer.add(@stateHistory, gameState)
        gameState

      when "nothing"
        console.log "'nothing' action returned.  This is not preferrable."
        null

      else
        throw new Error("WTF Transforms.selectAction returned unknown action #{action.toJS()}")

    # Update the view:
    @viewMachine.uiState.drawHitBoxes = @adminState.get('drawHitBoxes')
    @viewMachine.update2 gameState if gameState?

    # Update the component inspector:
    @componentInspectorMachine.update2 gameState if gameState?

createViewSystems = ->
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


createControllerEventMux = ->
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

  new ControllerEventMux(
    admin: adminController
    debug: debugController
    p1Keyboard: keyboardController
    p1Gamepad: gamepadController
  )

module.exports = MetroidCloneDelegate
