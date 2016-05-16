React = require 'react'
{div,span,table,tbody,td,tr} = React.DOM
Immutable = require 'immutable'
{Map,List} = Immutable

AdminToggles = require './admin_toggles'
HistorySlider = require './history_slider'


RollingHistory = require '../utils/rolling_history'
EntityStore = require '../ecs/entity_store'
Inspector = require './inspector'


AdminUI = React.createClass
  displayName: 'AdminUI'
  getInitialState: ->
    {}

  render: ->
    div {},
      React.createElement AdminToggles, address: @props.address, admin: @props.admin
      React.createElement HistorySlider, address: @props.address, history: @props.history
      Inspector.createEntityInspector @props.history

# view : (Address, admin) -> ReactElement
exports.view = (address, s) ->
  React.createElement(AdminUI, {
    address: address
    admin: s.admin
    history: s.history
  })
  
