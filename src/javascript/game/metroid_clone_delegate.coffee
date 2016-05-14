Immutable = require 'immutable'
{Map,List}=Immutable

Transforms = require './transforms'

PostOffice = require '../flarp/post_office'
KeyboardController3 = require '../input/keyboard_controller3'

# KeyboardController = require '../input/keyboard_controller'
# KeyboardController2 = require '../input/keyboard_controller2'

GamepadController = require('../input/gamepad_controller')
# ControllerEventMux = require('../input/controller_event_mux')

ViewMachine = require '../view/view_machine'
ViewSystems = require '../view/systems'
UIState = require '../view/ui_state'
UIConfig = require '../view/ui_config'

ComponentInspectorMachine = require '../view/component_inspector_machine'

ImmRingBuffer = require '../utils/imm_ring_buffer'
RollingHistory = require '../utils/state_history2'
PressedReleased = require '../utils/pressed_released'
PR = PressedReleased

WorldMap = require './map/world_map'

GameStateMachine = require './states/game_state_machine'
TitleState = require './states/title'
Title2 = require './states/title2'
AdventureState = require './states/adventure'
Adventure2 = require './states/adventure2'
TheGame = require './states/the_game'
PowerupState = require './states/powerup'

ImmRingBuffer = require '../utils/imm_ring_buffer'

class MetroidCloneDelegate
  constructor: ({componentInspector,@devUI,@systemLogInspector}) ->

    @postOffice = new PostOffice()

    # @gameStateMachine = new GameStateMachine([
    #   TitleState
    #   AdventureState
    #   PowerupState
    # ])

    # @controllerEventMux = createControllerEventMux()

    @playerControllerMailbox = @postOffice.newMailbox()
    @playerController = new KeyboardController3(@playerControllerMailbox.address,
      "right": 'right'
      "left": 'left'
      "up": 'up'
      "down": 'down'
      "a": 'action2'
      "s": 'action1'
      "enter": 'start'
    )
    @playerControllerGpMailbox = @postOffice.newMailbox()
    @playerControllerGp = new KeyboardController3(@playerControllerGpMailbox.address,
      "DPAD_RIGHT": 'right'
      "DPAD_LEFT": 'left'
      "DPAD_UP": 'up'
      "DPAD_DOWN": 'down'
      "FACE_1": 'action2'
      "FACE_2": 'action1'
      "START_FORWARD": 'start'
    )

    @adminControllerMailbox = @postOffice.newMailbox()
    @adminController = new KeyboardController3(@adminControllerMailbox.address,
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
    )

    @dtMailbox = @postOffice.newMailbox()

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
      # controllers:
      #   player1: {}
      #   player2: {}
      #   debug1: {}
      #   admin: {}
      dt: 0
      static:
        worldMap: worldMap

    ########################################################################################
    # SIGNALLY STUFF 
    #
    # Per time slice, bundle ticks and controller events into an "input" structure
    inputBundler = (din) ->
      (events) ->
        input = din
        for e in events
          switch e.get('type')
            when 'Tick'
              input = input.set('dt',e.get('dt'))
            when 'ControllerEvent'
              isDown = ('down' == e.get('action'))
              input = input.setIn(['controllers' ,e.get('tag'), e.get('control')], isDown)
        input

    dtEvents = @dtMailbox.signal
      .map((dt) -> Map(type:'Tick',dt:dt))

    playerControlEvents = @playerControllerMailbox.signal
      .merge(@playerControllerGpMailbox.signal)
      .dropRepeats(Immutable.is)
      .map((event) -> event.set('tag','player1'))

    adminControlEvents = @adminControllerMailbox.signal
      .dropRepeats(Immutable.is)
      .map((event) -> event.set('tag','admin'))

    input = dtEvents
      .merge(playerControlEvents)
      .merge(adminControlEvents)
      .sliceOn(dtEvents)
      .map(inputBundler(@defaultInput))

    initialAdminState = Immutable.fromJS
      input: {}
      ctrl: {}
      actualDt: 16.66
      stepDt: 16.6
      paused: false
      muted: false
      drawHitBoxes: false

    toggle = (x) -> !x
      
    toggleProp = (map,prop) ->
      before = map.get(prop)
      map = map.update(prop, toggle)
      after = map.get(prop)
      map

    updateAdmin = (input,admin0) ->
      admin = admin0
        .set('input',input)
        .set('actualDt',input.get('dt'))
        .delete('truncate_history')
        .update('ctrl', (ctrl) -> PressedReleased.update(ctrl, input.getIn(['controllers','admin'])))

      ctrl = admin.get('ctrl')

      if ctrl.get('toggle_pausePressed')
        admin = toggleProp(admin,'paused')
        if !admin.get('paused')
          admin = admin.set('truncate_history',true)

      if ctrl.get('toggle_mutePressed')
        admin = toggleProp(admin,'muted')

      if ctrl.get('toggle_bounding_boxPressed')
        admin = toggleProp(admin,'drawHitBoxes')
       
      admin = if admin.get('paused')
        admin.set('replay_back',
          ctrl.get('time_walk_backPressed') or
          ctrl.get('time_scroll_back')
        ).set('replay_forward',
          ctrl.get('time_walk_forwardPressed') or
          ctrl.get('time_scroll_forward')
        ).set('step_forward',
          ctrl.get('step_forwardPressed')
        )
      else
        admin
          .set('replay_back',false)
          .set('replay_forward',false)
          .set('step_forward',false)

      return admin

    adminState = input
      .foldp(updateAdmin, initialAdminState)

    # Game state value over time:
    updateGame = (input,s) ->
      [s1,_] = TheGame.update(s,input)
      return s1

    history0 = RollingHistory.add(RollingHistory.empty, TheGame.initialState())

    updateHistory = (admin, history) ->
      input = admin.get('input')
      game = RollingHistory.current(history)
      if admin.get('paused')
        if admin.get('replay_back')
          history = RollingHistory.back(history)
        else if admin.get('replay_forward')
          history = RollingHistory.forward(history)
        else if admin.get('step_forward')
          input1 = input.set('dt', admin.get('stepDt'))
          history = RollingHistory.truncate(history)
          history = RollingHistory.add(history, updateGame(input1, game))
      else
        if admin.get('truncate_history')
          history = RollingHistory.truncate(history)
        history = RollingHistory.add(history, updateGame(input,game))

      return history


    gameState = adminState
      # .foldp(adminStateToGameState, TheGame.initialState())
      .foldp(updateHistory, history0)
      .dropRepeats(Immutable.is)
      # .map (s) -> s.get('gameState')
      .map (hist) -> RollingHistory.current(hist).get('gameState')

    # When gameState changes, update view:
    gameState.subscribe (s) =>
      @viewMachine.update2(s)

  update: (dt) ->
    @dtMailbox.address.send dt
    @postOffice.sync()


  _update: (dt) ->
    empty = Map(admin: null, debug: null, p1Keyboard: null, p1Gamepad: null)
    controllerEvents = @controllerEventMux.next()
    # XXX:
    doDebug = false
    if !Immutable.is(controllerEvents,empty)
      console.log "controllerEvents:", controllerEvents.toJS()
      doDebug = true

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
        # input structure =
        #   dt: 16.6
        #   controllers:
        #     player1: 
        #       left: true
        #     debug1: null
        #   static:
        #     worldMap: ...
        #
        input = @defaultInput.merge(action.get('input'))
        # XXX:
        if doDebug
          console.log "action.get('input'):",action.get('input').toJS()
          console.log "input:", input.toJS()
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
  List(systemDefs).map (s) -> s.createInstance()


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
