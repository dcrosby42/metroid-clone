React = require 'react'
SystemLogUI = require './system_log_ui'

class SystemLogInspector
  constructor: ({@mountNode}) ->
    @_renderView(null)

  update: (input,systemLog,gameState) ->
    # if input? and systemLog? and gameState?
    #   console.log "SystemLogInspector: ",input.toJS(),systemLog.toJS(),gameState.toJS()
    if systemLog?
      @_renderView(systemLog)
      window.systemLog = systemLog

  _renderView: (systemLog) ->
    ui = React.createElement(SystemLogUI, systemLog: systemLog)
    React.render(ui, @mountNode)

module.exports = SystemLogInspector
