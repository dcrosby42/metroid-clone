React = require 'react'
{div,span,table,tbody,td,tr} = React.DOM
Immutable = require 'immutable'
{Map,List} = Immutable

RollingHistory = require '../utils/rolling_history'

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
    historySize = RollingHistory.size(h)
    historyIndex = h.get('index') + 1

    div {className:'history-slider'}, [
      div {className:'history-controls',key:'hcontrols'}, [
        React.createElement('span',{className:'control',key:'1',onClick: => @props.address.send(Map(type:'AdminUIEvent',name:'time_walk_back'))}, 'Back')
        React.createElement('span',{className:'control',key:'2',onClick: => @props.address.send(Map(type:'AdminUIEvent',name:'toggle_pause'))}, 'Pause')
        React.createElement('span',{className:'control',key:'3',onClick: => @props.address.send(Map(type:'AdminUIEvent',name:'time_walk_forward'))}, 'Forward')
        React.createElement('span',{key:'desc'}, "(#{h.get('index')+1} of #{historySize} ", "frames)")
      ]
      React.createElement('input',{type:'range',style:{width:"#{historySize}px"},min:1,max:historySize, value:historyIndex, onChange:@handleSlider,key:'range'})
    ]
      
module.exports = HistorySlider
