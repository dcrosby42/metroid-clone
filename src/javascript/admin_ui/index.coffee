React = require 'react'
{div,span,table,tbody,td,tr} = React.DOM
Immutable = require 'immutable'
{Map,List} = Immutable

RollingHistory = require '../utils/rolling_history'
EntityStore = require '../ecs/entity_store'

AdminToggles = require './admin_toggles'
HistorySlider = require './history_slider'
Inspector = require './inspector'
SystemLogUI = require './system_log_ui'

AdminUI = React.createClass
  displayName: 'AdminUI'
  getInitialState: ->
    {}

  render: ->
    div {},
      React.createElement AdminToggles, address: @props.address, admin: @props.admin
      React.createElement HistorySlider, address: @props.address, history: @props.history
      Inspector.createEntityInspector @props.history
      createSystemLogUI @props.history

createSystemLogUI = (h) ->
  slog = RollingHistory.current(h).get('systemLogs')
  # console.log slog
  React.createElement SystemLogUI, systemLog: Immutable.fromJS(slog)

# view : (Address, admin) -> ReactElement
exports.view = (address, s) ->
  # window['$S'] = s
  # window.RollingHistory = RollingHistory
  React.createElement(AdminUI, {
    address: address
    admin: s.admin
    history: s.history
  })
  

