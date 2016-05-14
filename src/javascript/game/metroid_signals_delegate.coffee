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

RollingHistory = require '../utils/state_history2'

TheGame = require './states/the_game'
Admin = require './states/admin'

AdminUI = require '../admin_ui'


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
        when 'AdminUIEvent'
          input = input.update 'adminUIEvents', (es) ->
            (es or Map()).set(e.get('name'),true)
    input

createKeyboardSignal = (postOffice, mappings) ->
  mbox = postOffice.newMailbox()
  KeyboardController3.bindKeys mbox.address, mappings
  return mbox.signal

createGamepadSignal = (postOffice, mappings) ->
  mbox = postOffice.newMailbox()
  GamepadController2.bindButtons mbox.address, mappings
  return mbox.signal

class MetroidSignalsDelegate
  constructor: ({componentInspector,adminUIDiv,@systemLogInspector}) ->

    @postOffice = new PostOffice()

    @player1KbController = createKeyboardSignal @postOffice,
      "right": 'right'
      "left": 'left'
      "up": 'up'
      "down": 'down'
      "a": 'action2'
      "s": 'action1'
      "enter": 'start'

    @player1GpController = createGamepadSignal @postOffice,
      "DPAD_RIGHT": 'right'
      "DPAD_LEFT": 'left'
      "DPAD_UP": 'up'
      "DPAD_DOWN": 'down'
      "FACE_1": 'action2'
      "FACE_3": 'action1'
      "START_FORWARD": 'start'

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

    @adminUI = new AdminUI(@postOffice,adminUIDiv)

    @dtMailbox = @postOffice.newMailbox()
    @dtSignal = @dtMailbox.signal

    if componentInspector?
      @componentInspectorMachine = new ComponentInspectorMachine(
        componentInspector: componentInspector
      )

  # dataToPreload: ->
  #   # TODO move this data to AdventureState?
  #   {
  #     world_map: "data/world_map.json"
  #   }
  #
  # graphicsToPreload: ->
  #   assets = AdventureState.graphicsToPreload()
  #   assets = assets.concat(TitleState.graphicsToPreload())
  #   assets
  #
  # soundsToPreload: ->
  #   sounds = AdventureState.soundsToPreload()
  #   sounds = _.merge(sounds, TitleState.soundsToPreload())
  #   sounds

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
    window.spriteConfigs = spriteConfigs #XXX
    uiConfig = UIConfig.create
      worldMap: worldMap
      spriteConfigs: spriteConfigs
      
    viewSystems = createViewSystems()

    @viewMachine = new ViewMachine
      systems: viewSystems
      uiConfig: uiConfig
      uiState: uiState


    ########################################################################################
    #
    # SIGNALLY STUFF 
    #

    dtEvents = @dtSignal
      .map((dt) -> Map(type:'Tick',dt:dt))

    adminUIEvents = @adminUI.signal

    playerControlEvents = @player1KbController.merge(@player1GpController)
      .dropRepeats(Immutable.is)
      .map((event) -> event.set('tag','player1'))

    adminControlEvents = @adminController
      .dropRepeats(Immutable.is)
      .map((event) -> event.set('tag','admin'))


    # For each time slice, smush all events into a composite 'input' structure
    defaultInput = Immutable.fromJS
      controllers: {}
      dt: 0
      static:
        worldMap: worldMap

    input = dtEvents
      .merge(playerControlEvents)
      .merge(adminControlEvents)
      .merge(adminUIEvents)      # all dt, keybd and gp events into one stream
      .sliceOn(dtEvents)         # batch up the events in an array and release on arrival of dt event
      .map(inputBundler(defaultInput)) # compile the 'input' structure (controller states, dt and static game data)


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

    initialHistory = RollingHistory.add(RollingHistory.empty, TheGame.initialState())

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

    #
    # OUTPUT
    #

    # Funnel game updates into the view:
    innerGameState.subscribe (s) =>
      @viewMachine.update(s)

    # Funnel game updates into the component inspector:
    if @componentInspectorMachine?
      innerGameState.subscribe (s) =>
        @componentInspectorMachine.update s

    # Funnel game state into a global var for Console debugging:
    innerGameState.subscribe (s) -> window.gamestate = s
    
    # Funnel admin state into viewMachine's uiState debug stuff, and to the adminUI
    adminState.subscribe (s) =>
      @adminUI.update(s)
      @viewMachine.setMute s.get('muted')
      @viewMachine.setDrawHitBoxes s.get('drawHitBoxes')



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
