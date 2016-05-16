React = require 'react'
{div,span,table,tbody,td,tr} = React.DOM

Immutable = require 'immutable'
{Map,List} = Immutable

RollingHistory = require './utils/state_history2'
EntityStore = require './ecs/entity_store'
InspectorUI = require './inspector/inspector_ui'

classnames = require 'classnames'



createToggleLi = (address,text,action,state) ->
  sendAction = -> address.send Map(type: 'AdminUIEvent', name: action)
  React.createElement('li', {onClick: sendAction, className:classnames(enabled:state)}, text)

# AdminToggles = (props) ->
#   React.createElement 'ul', {className: 'toggles'},
#     createToggleLi props.address, "[P]ause", 'toggle_pause', props.admin.get('paused')
#     createToggleLi props.address, "[M]ute", 'toggle_mute', props.admin.get('muted')
#     createToggleLi props.address, "[D]raw Hit Boxes", 'toggle_bounding_box', props.admin.get('drawHitBoxes')
AdminToggles = React.createClass
  displayName: 'AdminToggles'
  render: ->
    React.createElement 'ul', {className: 'toggles'},
      createToggleLi @props.address, "[P]ause", 'toggle_pause', @props.admin.get('paused')
      createToggleLi @props.address, "[M]ute", 'toggle_mute', @props.admin.get('muted')
      createToggleLi @props.address, "[D]raw Hit Boxes", 'toggle_bounding_box', @props.admin.get('drawHitBoxes')

AdminUI = React.createClass
  displayName: 'AdminUI'
  getInitialState: ->
    {}

  render: ->
    div {},
      React.createElement AdminToggles, address: @props.address, admin: @props.admin
      React.createElement HistorySlider, address: @props.address, history: @props.history
      createEntityInspector @props.history


createEntityInspector = (h) ->
  gameState = RollingHistory.current(h).get('gameState')
  estore = new EntityStore(gameState)

  entities = Map()
  estore.forEachComponent (comp) ->
    eid = comp.get('eid')
    cid = comp.get('cid')
    entities = entities.setIn([eid,cid], comp)

  React.createElement InspectorUI,
    entities: entities
    entityStore: estore
    inspectorConfig: Immutable.fromJS
      componentLayout:
        samus:      { open: false }
        skree:      { open: false }
        zoomer:      { open: false }
        hit_box:      { open: false }
        controller: { open: false }
        animation:     { open: false }
        velocity:   { open: false }
        position:   { open: false }




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
      div {}, "#{h.get('index')+1} of #{historySize} ", "frames"
      div {className:'history-controls'}, [
        React.createElement('span',{className:'control',onClick: => @props.address.send(Map(type:'AdminUIEvent',name:'time_walk_back'))}, 'Back')
        React.createElement('span',{className:'control',onClick: => @props.address.send(Map(type:'AdminUIEvent',name:'toggle_pause'))}, 'Pause')
        React.createElement('span',{className:'control',onClick: => @props.address.send(Map(type:'AdminUIEvent',name:'time_walk_forward'))}, 'Forward')
      ]
      React.createElement('input',{type:'range',style:{width:"#{historySize}px"},min:1,max:historySize, value:historyIndex, onChange:@handleSlider})
    ]
      

# view : (Address, admin) -> ReactElement
exports.view = (address, s) ->
  React.createElement(AdminUI, {
    address: address
    admin: s.admin
    history: s.history
  })
  
