Immutable = require 'immutable'

Transforms = require './transforms'

KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')
ControllerEventMux = require('../input/controller_event_mux')

ViewMachine = require '../view/view_machine'
ViewSystems = require '../view/systems'
UIState = require '../view/ui_state'
UIConfig = require '../view/ui_config'

ComponentInspectorMachine = require '../view/component_inspector_machine'

ImmRingBuffer = require '../utils/imm_ring_buffer'

WorldMap = require './map/world_map'

GameStateMachine = require './states/game_state_machine'
TitleState = require './states/title'
AdventureState = require './states/adventure'
PowerupState = require './states/powerup'

ImmRingBuffer = require '../utils/imm_ring_buffer'

class MetroidCloneDelegate
  constructor: ({componentInspector,@devUI,@systemLogInspector}) ->

    @gameStateMachine = new GameStateMachine([
      TitleState
      AdventureState
      PowerupState
    ])


    @controllerEventMux = createControllerEventMux()

    if componentInspector?
      @componentInspectorMachine = new ComponentInspectorMachine(
        componentInspector: componentInspector
      )

    @adminState = Immutable.fromJS
      controller:{}
      paused: false
      muted: true
      # muted: false
      drawHitBoxes: false

    @stateHistory = ImmRingBuffer.create(5*60)

  dataToPreload: ->
    # TODO move this data to AdventureState?
    {
      world_map: "data/world_map.json"
    }

  graphicsToPreload: ->
    assets = AdventureState.graphicsToPreload()
    assets = assets.concat(TitleState.graphicsToPreload())
    assets

  soundsToPreload: ->
    sounds = AdventureState.soundsToPreload()
    sounds = _.merge(sounds, TitleState.soundsToPreload())
    sounds

  setupStage: (stage, width, height,zoom, soundController, data) ->

    worldMap = WorldMap.buildMap(data['world_map'])
    window.worldMap = worldMap # XXX
    
    uiState = UIState.create
      stage: stage
      zoomScale: zoom
      soundController: soundController
      aspectScale:
        x: 1.25
        y: 1

    uiConfig = UIConfig.create
      worldMap: worldMap
      spriteConfigs: AdventureState.spriteConfigs()
      
    viewSystems = createViewSystems()

    @viewMachine = new ViewMachine
      systems: viewSystems
      uiConfig: uiConfig
      uiState: uiState

    @defaultInput = Immutable.fromJS
      controllers:
        player1: {}
        player2: {}
        debug1: {}
        admin: {}
      dt: 0
      static:
        worldMap: worldMap

  update: (dt) ->
    controllerEvents = @controllerEventMux.next()
    # Dumb temp hack: smush gamepad events onto keyboard events  XXX
    gpe = controllerEvents.get('p1Gamepad')
    if gpe?
      console.log gpe.toJS()
      controllerEvents = controllerEvents.update 'p1Keyboard', (k) ->
        if k?
          k.merge(gpe)
        else
          gpe
      


    devUIEvents = @devUI.getEvents()

    priorAdminState = @adminState
    @adminState = Transforms.updateAdmin(@adminState, controllerEvents.get('admin'), devUIEvents)

    [@stateHistory, action] = Transforms.selectAction(@stateHistory,dt,controllerEvents,@adminState)
    gameState = null
    input = null
    systemLog = null
    switch action.get('type')
      when "useState"
        systemLog = action.get('systemLog')
        input = action.get('input')
        gameState = action.get('gameState')

      when "computeState"
        input = @defaultInput.merge(action.get('input'))
        [gameState,systemLog] = @gameStateMachine.update(input)
        @stateHistory = ImmRingBuffer.add(@stateHistory, {input:input, systemLog: systemLog, gameState:gameState})
        systemLog = null # don't update the inspector during normal runtime

      when "nothing"
        throw new Error("'nothing' action returned.  This is not preferrable.")
      else
        throw new Error("WTF Transforms.selectAction returned unknown action #{action.toJS()}")

    # Update the view based on admin controls and updated gamestate
    if !Immutable.is(@adminState, priorAdminState)
      if !@adminState.get('muted')
        if @adminState.get('paused')
          @viewMachine.uiState.muteAudio()
        else
          @viewMachine.uiState.unmuteAudio()

      if !@adminState.get('paused')
        if @adminState.get('muted')
          @viewMachine.uiState.muteAudio()
        else
          @viewMachine.uiState.unmuteAudio()

    @viewMachine.uiState.drawHitBoxes = @adminState.get('drawHitBoxes')
    @viewMachine.update2 gameState if gameState?

    # Update the component inspector:
    if @componentInspectorMachine? and gameState?
      @componentInspectorMachine.update gameState

    if @systemLogInspector? and systemLog?
      @systemLogInspector.update(input,systemLog,gameState)

    @devUI.setState(@adminState)

createViewSystems = ->
  systemDefs = [
    ViewSystems.animation_sync_system
    ViewSystems.label_sync_system
    ViewSystems.ellipse_sync_system
    ViewSystems.rectangle_sync_system
    ViewSystems.hit_box_visual_sync_system
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
    "START_FORWARD": 'start'


  adminController = new KeyboardController
    bindings:
      "g": 'toggle_gamepad'
      "b": 'toggle_bgm'
      "p": 'toggle_pause'
      "m": 'toggle_mute'
      "d": 'toggle_bounding_box'
      # "m": 'cycle_admin_mover'
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
