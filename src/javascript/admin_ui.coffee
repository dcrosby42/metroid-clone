React = require 'react'
# Slider = require('react-rangeslider')
# ReactSlider = require('react-slider')

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
    div {},
      React.createElement 'ul', {className: 'toggles'},
        createToggleLi @props.address, "[P]ause", 'toggle_pause', @props.admin.get('paused')
        createToggleLi @props.address, "[M]ute", 'toggle_mute', @props.admin.get('muted')
        createToggleLi @props.address, "[D]raw Hit Boxes", 'toggle_bounding_box', @props.admin.get('drawHitBoxes')

      React.createElement HistorySlider, address: @props.address, history: @props.history

HistorySlider = React.createClass
  displayName: 'HistorySlider'
  getInitialState: ->
    { value: 0 }

  handleSlider: (e) ->
    value = parseInt(e.target.value)
    @props.address.send(Map(type:'AdminUIEvent',name:'history_jump_to',data:value))


  handleClick: (e) ->
    console.log "AdminUI.handleClick",e

  render: ->
    h = @props.history
    fullSize = h.get('maxSize')
    currSize = RollingHistory.size(h)
    currLoc = h.get('index') + 1
    div {}, [
      div {}, "#{h.get('index')+1} of #{currSize} ", "frames"
      div {className:'history-controls'}, [
        React.createElement('span',{className:'control',onClick: => @props.address.send(Map(type:'AdminUIEvent',name:'time_walk_back'))}, 'Back')
        React.createElement('span',{className:'control',onClick: => @props.address.send(Map(type:'AdminUIEvent',name:'toggle_pause'))}, 'Pause')
        React.createElement('span',{className:'control',onClick: => @props.address.send(Map(type:'AdminUIEvent',name:'time_walk_forward'))}, 'Forward')
      ]
      # div {className: "history-meter", onMouseMove: @handleMouseMove, onMouseDown: @handleMouseDown, onMouseUp: @handleMouseUp, style: {width:"#{currSize}px"}}, [
      #   div {className: "history-meter-fill", style: {width:"#{currLoc}px"}}, []
      # ]
      React.createElement('input',{type:'range',style:{width:"#{currSize}px"},min:1,max:currSize, value:currLoc, onChange:@handleSlider})
    ]
      

# view : (Address, admin) -> ReactElement
exports.view = (address, s) ->
  React.createElement(AdminUI, {
    address: address
    admin: s.admin
    history: s.history
  })
  
