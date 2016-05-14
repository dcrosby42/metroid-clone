Immutable = require 'immutable'
{Map,List}=Immutable

PostOffice = require '../flarp/post_office'

KeyboardController3 = require '../input/keyboard_controller3'
GamepadController2 = require('../input/gamepad_controller2')

ViewMachine = require '../view/view_machine'
ViewSystems = require '../view/systems'
UIState = require '../view/ui_state'
UIConfig = require '../view/ui_config'

ComponentInspectorMachine = require '../view/component_inspector_machine'

WorldMap = require './map/world_map'

TitleState = require './states/title'
AdventureState = require './states/adventure'

RollingHistory = require '../utils/state_history2'

TheGame = require './states/the_game'
Admin = require './states/admin'


#
# HELPERS
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

class MetroidSignalsDelegate
  constructor: ({componentInspector,@devUI,@systemLogInspector}) ->

    @postOffice = new PostOffice()

    @playerControllerMailbox = @postOffice.newMailbox()
    KeyboardController3.bindKeys @playerControllerMailbox.address,
      "right": 'right'
      "left": 'left'
      "up": 'up'
      "down": 'down'
      "a": 'action2'
      "s": 'action1'
      "enter": 'start'

    @playerControllerGpMailbox = @postOffice.newMailbox()
    GamepadController2.bindButtons @playerControllerGpMailbox.address,
      "DPAD_RIGHT": 'right'
      "DPAD_LEFT": 'left'
      "DPAD_UP": 'up'
      "DPAD_DOWN": 'down'
      "FACE_1": 'action2'
      "FACE_3": 'action1'
      "START_FORWARD": 'start'

    @adminControllerMailbox = @postOffice.newMailbox()
    KeyboardController3.bindKeys @adminControllerMailbox.address,
      "g": 'toggle_gamepad'
      "b": 'toggle_bgm'
      "p": 'toggle_pause'
      "m": 'toggle_mute'
      "d": 'toggle_bounding_box'
      "<": 'time_walk_back'
      ">": 'time_walk_forward'
      ",": 'time_scroll_back'
      ".": 'time_scroll_forward'
      "h": 'left'
      "j": 'down'
      "k": 'up'
      "l": 'right'
      "space": 'step_forward'

    @dtMailbox = @postOffice.newMailbox()

    # TODO
    # if componentInspector?
    #   @componentInspectorMachine = new ComponentInspectorMachine(
    #     componentInspector: componentInspector
    #   )

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
      controllers: {}
      dt: 0
      static:
        worldMap: worldMap

    ########################################################################################
    # SIGNALLY STUFF 
    #

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


    adminState = input
      .foldp(Admin.update, Admin.initialState())

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
      .foldp(updateHistory, history0)
      .dropRepeats(Immutable.is)
      .map (hist) -> RollingHistory.current(hist).get('gameState')

    # When gameState changes, update view:
    gameState.subscribe (s) =>
      @viewMachine.update2(s)

  update: (dt) ->
    @dtMailbox.address.send dt
    @postOffice.sync()


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

module.exports = MetroidSignalsDelegate
