React = require 'react'
{div,span,table,tbody,td,tr} = React.DOM
Immutable = require 'immutable'
{Map,List} = Immutable

RollingHistory = require '../utils/rolling_history'
EntityStore = require '../ecs/entity_store'

AdminToggles = require './admin_toggles'
HistorySlider = require './history_slider'
EntityInspector = require './entity_inspector'
SystemLogUI = require './system_log_ui'
Folder = require './folder'


AdminUI = React.createClass
  displayName: 'AdminUI'
  getInitialState: ->
    {}

  render: ->
    div {},
      Folder.create {title:'Dev Controls',startOpen:false}, => [
        React.createElement AdminToggles, address: @props.address, admin: @props.admin
        React.createElement HistorySlider, address: @props.address, history: @props.history
      ]
      Folder.create {title:'Entities'}, =>
        EntityInspector.create(@props.history)
      # Folder.create {title:'Entities (Alt)'}, =>
      #   EntityInspector.create2(@props.history)
      Folder.create {title:'Systems'}, =>
        SystemLogUI.create(@props.history)

# view : (Address, admin) -> ReactElement
exports.view = (address, s) ->
  React.createElement(AdminUI, {
    address: address
    admin: s.admin
    history: s.history
  })
  

