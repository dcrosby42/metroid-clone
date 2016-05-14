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
    actualDt: 16.66
    stepDt: 16.6
    paused: false
    muted: false
    drawHitBoxes: false

exports.update = (input,admin) ->
  admin = admin
    .set('input',input)
    .set('actualDt',input.get('dt'))
    .delete('truncate_history')
    .update('ctrl', (ctrl) ->
      PressedReleased.update(ctrl, input.getIn(['controllers','admin'])))

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
