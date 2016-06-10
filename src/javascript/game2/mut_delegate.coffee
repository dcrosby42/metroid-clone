React = require 'react'
ReactDOM = require 'react-dom'
Immutable = require 'immutable'
{Map,List}=Immutable

PostOffice = require '../flarp/post_office'

KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')

#ViewMachine = require '../view/view_machine'
MutViewMachine = require '../view2/view_machine'
# ViewSystems = require '../view/systems'
MutViewSystems = require '../view2/systems'
UIState = require '../view2/ui_state'
UIConfig = require '../view/ui_config'

WorldMap = require '../game/map/world_map'

# RollingHistory = require '../utils/rolling_history'

TheMutGame = require './states/the_game'

# Admin = require './stategame/s/admin'
# AdminUI = require '../admin_ui'

#
# HELPERS
#

# Per time slice, bundle ticks and controller events into an "input" structure
inputBundler = (baseInput) ->
  (events) ->
    input = baseInput
    for e in events
      switch e.get('type')
        when 'Tick'
          input = input.set('dt',e.get('dt'))
        when 'ControllerEvent'
          isDown = ('down' == e.get('action'))
          input = input.setIn(['controllers' ,e.get('tag'), e.get('control')], isDown)
        when 'AdminUIEvent'
          input = input.update 'adminUIEvents', (es) ->
            (es or Map()).set(e.get('name'),if e.has('data') then e.get('data') else true)
    input

createKeyboardSignal = (postOffice, mappings) ->
  mbox = postOffice.newMailbox()
  KeyboardController.bindKeys mbox.address, mappings
  return mbox.signal

createGamepadSignal = (postOffice, mappings) ->
  mbox = postOffice.newMailbox()
  GamepadController.bindButtons mbox.address, mappings
  return mbox.signal

class MutDelegate
  constructor: ({componentInspector,@adminUIDiv}) ->

    @postOffice = new PostOffice()

    @player1KbController = createKeyboardSignal @postOffice,
      "right": 'right'
      "left": 'left'
      "up": 'up'
      "down": 'down'
      "a": 'action2'
      "s": 'action1'
      "enter": 'start'
      "shift": 'select'

    @player1GpController = createGamepadSignal @postOffice,
      "DPAD_RIGHT": 'right'
      "DPAD_LEFT": 'left'
      "DPAD_UP": 'up'
      "DPAD_DOWN": 'down'
      "FACE_1": 'action2'
      "FACE_3": 'action1'
      "START_FORWARD": 'start'
      "SELECT_BACK": 'select'

    @adminController = createKeyboardSignal @postOffice,
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

    @adminUIMailbox = @postOffice.newMailbox()
    @adminUIAddress = @adminUIMailbox.address
    @adminUISignal = @adminUIMailbox.signal

    @timeMailbox = @postOffice.newMailbox()
    @time = @timeMailbox.signal

  assetsToPreload: ->
    # TheMutGame.assetsToPreload().toJS()
    TheMutGame.assetsToPreload()#.toJS()

  initialize: (stage, width, height,zoom, soundController, data) ->
    worldMap = WorldMap.buildMap(data['world_map'])
    
    uiState = UIState.create
      stage: stage
      zoomScale: zoom
      soundController: soundController
      aspectScale:
        x: 1.25
        y: 1

    spriteConfigs = TheMutGame.spriteConfigs()
    uiConfig = UIConfig.create
      worldMap: worldMap
      spriteConfigs: spriteConfigs
      
    viewSystems = createMutViewSystems()
    @mutViewMachine = new MutViewMachine
      systems: viewSystems
      uiConfig: uiConfig
      uiState: uiState


    @defaultInput = Immutable.fromJS
      controllers: {}
      dt: 0
      static:
        worldMap: worldMap


    @_wireUp_mutable()

  _wireUp_mutable: ->
    tick = @time.map((dt) -> Map(type:'Tick',dt:dt))

    playerControl = @player1KbController.merge(@player1GpController)
      .dropRepeats(Immutable.is)
      .map((event) -> event.set('tag','player1'))

    input = tick
      .merge(playerControl)
      .sliceOn(tick)             # batch up the events in an array and release that array on arrival of dt event
      .map(inputBundler(@defaultInput)) # compile the 'input' structure (controller states, dt and static game data)

    updateGame = (input,s) ->
      # console.log "updateGame", input, s
      window.State = s
      TheMutGame.update(s,input)

    state = input
      .foldp(updateGame, TheMutGame.initialState())
    
    # Funnel game updates into the view:
    state.subscribe (s) =>
      @mutViewMachine.update(s.gameState)

  update: (dt) ->
    @timeMailbox.address.send dt
    @postOffice.sync()


createMutViewSystems = ->
  [
    MutViewSystems.animation_sync_system()
    MutViewSystems.label_sync_system()
    # MutViewSystems.ellipse_sync_system
    # MutViewSystems.rectangle_sync_system
    # MutViewSystems.hit_box_visual_sync_system
    MutViewSystems.viewport_sync_system()
    # MutViewSystems.sound_sync_system
    MutViewSystems.room_sync_system()
  ]
  # List(systemDefs).map (s) -> s.createInstance()

module.exports = MutDelegate
