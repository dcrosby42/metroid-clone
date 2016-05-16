React = require 'react'
{div,span,table,tbody,td,tr,th,ul,li} = React.DOM
Immutable = require 'immutable'
RollingHistory = require '../utils/rolling_history'
Structures = require './structures'


SystemLogUI = React.createClass
  displayName: 'SystemLogUI'

  render: ->
    React.createElement Structures.Map, className: 'systemLog', data: @props.systemLog

SystemLogUI.create = (history) ->
  slog = RollingHistory.current(history).get('systemLogs')
  React.createElement SystemLogUI, systemLog: Immutable.fromJS(slog)

module.exports = SystemLogUI
