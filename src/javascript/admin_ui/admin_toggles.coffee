React = require 'react'
Immutable = require 'immutable'
{Map,List} = Immutable
classnames = require 'classnames'

createToggleLi = (address,text,action,state) ->
  sendAction = -> address.send Map(type: 'AdminUIEvent', name: action)
  React.createElement('li', {onClick: sendAction, className:classnames(enabled:state)}, text)

AdminToggles = (props) ->
  React.createElement 'ul', {className: 'toggles'},
    createToggleLi props.address, "[P]ause", 'toggle_pause', props.admin.get('paused')
    createToggleLi props.address, "[M]ute", 'toggle_mute', props.admin.get('muted')
    createToggleLi props.address, "[D]raw Hit Boxes", 'toggle_bounding_box', props.admin.get('drawHitBoxes')

module.exports = AdminToggles
