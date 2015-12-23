PressedReleased = require '../utils/pressed_released'
Immutable = require 'immutable'
imm = Immutable.fromJS
ImmRingBuffer = require '../utils/imm_ring_buffer'

GameControlMappings = Immutable.Map
  player1: 'p1Keyboard'
  debug1: 'debug'

mapControllerEvents = (events,mappings) ->
  mappings.reduce (controllers, src,dest) ->
    controllers.set dest, events.get(src)
  , Immutable.Map()

exports.updateAdmin = (admin, cevts) ->
  controller = PressedReleased.update(admin.get('controller'),cevts)
  admin = admin.set('controller', controller)

  if controller.get('toggle_pausePressed')
    admin = admin.update 'paused', (p) -> !p
   
  admin = if admin.get('paused')
    admin.set('replay_back',
      controller.get('time_walk_backPressed') or
      controller.get('time_scroll_back')
    ).set('replay_forward',
      controller.get('time_walk_forwardPressed') or
      controller.get('time_scroll_forward')
    ).set('step_forward',
      controller.get('step_forwardPressed')
    )
  else
    admin
      .set('replay_back',false)
      .set('replay_forward',false)
      .set('step_forward',false)
      
  admin

exports.selectAction = (stateHistory,dt,controllerEvents,adminState) ->
  gameState1 = null
  events = null
  if adminState.get('paused')
    if adminState.get('replay_forward')
      stateHistory = ImmRingBuffer.forward(stateHistory)
      gameState1 = ImmRingBuffer.read(stateHistory)
      if gameState1 == null
        return [stateHistory,imm(type:"nothing")]
      action = imm(type:'useState', gameState:gameState1)
      return [stateHistory, action]

    else if adminState.get('replay_back')
      stateHistory = ImmRingBuffer.backward(stateHistory)
      gameState1 = ImmRingBuffer.read(stateHistory)
      if gameState1 == null
        return [stateHistory,imm(type:"nothing")]
      action = imm(type:'useState', gameState:gameState1)
      return [stateHistory, action]

    else if adminState.get('step_forward')
      # paused, step forward one nominal time slice. 17 =~ 16.666
      input = imm(dt: 17, controllers: mapControllerEvents(controllerEvents,GameControllerMappings))
      action = imm(type:'computeState', input: input)
      return [stateHistory,action]

    else
      # paused. no change.
      gameState1 = ImmRingBuffer.read(stateHistory)
      if gameState1 == null
        return [stateHistory,imm(type:"nothing")]
      action = imm(type:'useState', gameState:gameState1)
      return [stateHistory, action]

  action = imm(type:'computeState',input: {dt: dt, controllers: mapControllerEvents(controllerEvents,GameControlMappings)})
  return [stateHistory, action]
