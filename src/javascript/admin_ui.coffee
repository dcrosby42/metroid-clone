React = require 'react'
Immutable = require 'immutable'
RollingHistory = require './utils/state_history2'
{Map,List} = Immutable

{div,span,table,tbody,td,tr} = React.DOM

createToggleLi = (address,text,action,state) ->
  attrs = {}
  attrs.className = "enabled" if state
  attrs.onClick = ->
    address.send Map(type: 'AdminUIEvent', name: action)
  React.createElement('li', attrs, text)

AdminUI = React.createClass
  displayName: 'AdminUI'
  getInitialState: ->
    {}

  render: ->
    h = @props.history
    div {},
      React.createElement 'ul', {className: 'toggles'},
        createToggleLi @props.address, "[P]ause", 'toggle_pause', @props.admin.get('paused')
        createToggleLi @props.address, "[M]ute", 'toggle_mute', @props.admin.get('muted')
        createToggleLi @props.address, "[D]raw Hit Boxes", 'toggle_bounding_box', @props.admin.get('drawHitBoxes')
        React.createElement('li',{onClick: => @props.address.send(Map(type:'AdminUIEvent',name:'time_walk_back'))}, '<<')
        React.createElement('li',{onClick: => @props.address.send(Map(type:'AdminUIEvent',name:'time_walk_forward'))}, '>>')

      div {}, "#{h.get('index')+1} of #{RollingHistory.size(h)} frames"

# view : (Address, admin) -> ReactElement
exports.view = (address, s) ->
  React.createElement(AdminUI, {
    address: address
    admin: s.admin
    history: s.history
  })
  
