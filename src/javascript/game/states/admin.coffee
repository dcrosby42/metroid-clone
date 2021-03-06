Immutable = require 'immutable'
{Map,List} = Immutable
PressedReleased = require '../../utils/pressed_released'

toggle = (x) -> !x
  
toggleProp = (map,prop) ->
  before = map.get(prop)
  map = map.update(prop, toggle)
  after = map.get(prop)
  map
    
exports.initialState = () ->
  Immutable.fromJS
    input: {}
    ctrl: {}
    stepDt: 16.6
    paused: false
    muted: false
    drawHitBoxes: false

exports.update = (input,admin) ->
  admin = admin
    .set('input',input)
    .delete('truncate_history')
    .update('ctrl', (ctrl) ->
      PressedReleased.update(ctrl, input.getIn(['controllers','admin'])))

  ctrl = admin.get('ctrl')
  uiEvents = input.get('adminUIEvents') or Map()

  if ctrl.get('toggle_pausePressed') or uiEvents.get('toggle_pause')
    admin = toggleProp(admin,'paused')
    if !admin.get('paused')
      admin = admin.set('truncate_history',true)

  if ctrl.get('toggle_mutePressed') or uiEvents.get('toggle_mute')
    admin = toggleProp(admin,'muted')

  if ctrl.get('toggle_bounding_boxPressed') or uiEvents.get('toggle_bounding_box')
    admin = toggleProp(admin,'drawHitBoxes')

  admin = if admin.get('paused')
    admin = admin.set('replay_back',
      ctrl.get('time_walk_backPressed') or
      ctrl.get('time_scroll_back') or
      uiEvents.get('time_walk_back')
    ).set('replay_forward',
      ctrl.get('time_walk_forwardPressed') or
      ctrl.get('time_scroll_forward') or
      uiEvents.get('time_walk_forward')
    ).set('step_forward',
      ctrl.get('step_forwardPressed')
    )
    admin = if uiEvents.has('history_jump_to')
      admin.set('history_jump_to', uiEvents.get('history_jump_to'))
    else
      admin.delete('history_jump_to')
    admin
  else
    admin
      .set('replay_back',false)
      .set('replay_forward',false)
      .set('step_forward',false)
      .delete('history_jump_to')

  return admin
