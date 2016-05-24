React = require 'react'
ReactDOM = require 'react-dom'
Immutable = require 'immutable'
{Map,List}=Immutable

PostOffice = require '../flarp/post_office'

KeyboardController = require '../input/keyboard_controller'
GamepadController = require('../input/gamepad_controller')

ViewMachine = require '../view/view_machine'
ViewSystems = require '../view/systems'
UIState = require '../view/ui_state'
UIConfig = require '../view/ui_config'

WorldMap = require './map/world_map'

RollingHistory = require '../utils/rolling_history'

TheGame = require './states/the_game'
Admin = require './states/admin'

AdminUI = require '../admin_ui'

EntityStore = require '../ecs/entity_store'

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

class MetroidDelegate
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
    TheGame.assetsToPreload().toJS()

  initialize: (stage, width, height,zoom, soundController, data) ->
    worldMap = WorldMap.buildMap(data['world_map'])
    
    uiState = UIState.create
      stage: stage
      zoomScale: zoom
      soundController: soundController
      aspectScale:
        x: 1.25
        y: 1

    spriteConfigs = TheGame.spriteConfigs()
    uiConfig = UIConfig.create
      worldMap: worldMap
      spriteConfigs: spriteConfigs
      
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


    # @_wireUp_production()
    @_wireUp_development()

  _wireUp_production: ->
    tick = @time.map((dt) -> Map(type:'Tick',dt:dt))

    playerControl = @player1KbController.merge(@player1GpController)
      .dropRepeats(Immutable.is)
      .map((event) -> event.set('tag','player1'))

    input = tick
      .merge(playerControl)
      .sliceOn(tick)             # batch up the events in an array and release that array on arrival of dt event
      .map(inputBundler(@defaultInput)) # compile the 'input' structure (controller states, dt and static game data)

    updateGame = (input,s) ->
      [s1,_] = TheGame.update(s,input)
      return s1

    state = input
      .foldp(updateGame, TheGame.initialState())
      .dropRepeats(Immutable.is)  # (if a new history is identical to the prior history, send no change)
    
    # Funnel game updates into the view:
    state.subscribe (s) =>
      @viewMachine.update(s.get('gameState'))


  _wireUp_development: ->
    ########################################################################################
    #
    # SIGNALLY STUFF 
    #

    tick = @time.map((dt) -> Map(type:'Tick',dt:dt))

    playerControl = @player1KbController.merge(@player1GpController)
      .dropRepeats(Immutable.is)
      .map((event) -> event.set('tag','player1'))

    adminControl = @adminController
      .dropRepeats(Immutable.is)
      .map((event) -> event.set('tag','admin'))


    # For each time slice, smush all events into a composite 'input' structure
    input = tick
      .merge(playerControl)
      .merge(adminControl)
      .merge(@adminUISignal)     # all dt, keybd and gp events into one stream
      .sliceOn(tick)             # batch up the events in an array and release that array on arrival of dt event
      .map(inputBundler(@defaultInput)) # compile the 'input' structure (controller states, dt and static game data)


    # The current state of the administrative controls: 
    adminState = input
      .foldp(Admin.update, Admin.initialState())

    #
    # Rollingistory: a value object containing a rolling list of game state values...
    # AND a pointer to where we are in that history.  (Often, current() is the most recently
    # calculated game state, but our admin state may decide to adjust it back or forward 
    # through the history buffer.)
    # 
    # As we calculate new game states, we accumulate a history of game states.
    #
    # This stage of the pipeline must produce an updated snapshot of the game universe
    # and our place in that universe.
    #
    # NOTE: 'game state' is a nebulous term.  TheGame's idea of state looks like {mode:'adventure', gameState:(entityStoreGuts)}.
    # Some code refers to 'game state' in this sense, other code (like the view machine) considers the 'entity store guts' to be game state.
    #

    # (convenience: simplify invocation of game engine updates)
    updateGame = (input,s) ->
      [s1,_] = TheGame.update(s,input)
      return s1

    initialHistory = RollingHistory.add(RollingHistory.empty.set('maxSize',10*60), TheGame.initialState())

    # Given a new admin state, change history....
    updateHistory = (admin, history) ->
      input = admin.get('input')
      game = RollingHistory.current(history)
      if admin.get('paused')
        # (when paused, admin controls may choose to alter history in specific ways)
        if admin.get('replay_back')
          history = RollingHistory.back(history)     #  ...by stepping back in time (min=oldest retained gamestate)
        else if admin.get('replay_forward')
          history = RollingHistory.forward(history)  #  ...by stepping forward in time (max=newest gamestate)
        else if jumpTo = admin.get('history_jump_to')
          history = RollingHistory.indexTo(history,jumpTo) # ...by jumping to a specific frame of history
        else if admin.get('step_forward')
          input1 = input.set('dt', admin.get('stepDt'))
          # (if we're currently in the past, step_forward starts a new timeline... wipe the previous future)
          history = RollingHistory.truncate(history)
          history = RollingHistory.add(history, updateGame(input1, game)) # ...by calc'ing a new gamestate due to single-frame step
      else
        # (the normal game-play scenario)
        if admin.get('truncate_history')
          # (if we're currently in the past, step_forward starts a new timeline... wipe the previous future)
          history = RollingHistory.truncate(history)
        history = RollingHistory.add(history, updateGame(input,game)) # ...by calc'ing the next "natural" gamestate based on dt and controller inputs

      return history

    # State of history over time:
    history = adminState
      .foldp(updateHistory, initialHistory)
      .dropRepeats(Immutable.is)  # (if a new history is identical to the prior history, send no change)

    innerGameState = history.map (h) ->
      RollingHistory.current(h).get('gameState')

    # TEMPORARY: plunk some global state out for console inspections:
    # history.map (h) ->
    #   window.$H = h
    #   window.$S = RollingHistory.current(h)
    #   window.$GS = window.$S.get('gameState')
    #   window.$ES ?= new EntityStore()
    #   window.$ES.restoreSnapshot($GS)


    #
    # OUTPUT
    #

    # Funnel game updates into the view:
    innerGameState.subscribe (s) =>
      @viewMachine.update(s)

    # (filter-down the admin state to be less volatile on dt and controllers n stuff)
    adminState2 = adminState
      .map((s) -> s.delete('input').delete('controllers'))
      .dropRepeats(Immutable.is)

    # Funnel admin state into viewMachine's uiState debug stuff
    adminState2.subscribe (s) =>
        @viewMachine.setMute s.get('muted')
        @viewMachine.setDrawHitBoxes s.get('drawHitBoxes')

    # bundle admin state and history together and feed it into the admin ui
    adminState2
      .mapN(
        ((admin,history,gameState) -> {admin:admin,history:history,gameState:gameState})
        history
        innerGameState)
      .dropRepeats(Immutable.is)
      .subscribe (combined) =>
          adminView = AdminUI.view(@adminUIAddress,combined)
          ReactDOM.render(adminView, @adminUIDiv)

  update: (dt) ->
    @timeMailbox.address.send dt
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

module.exports = MetroidDelegate
