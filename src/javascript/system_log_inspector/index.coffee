class SystemLogInspector
  update: (input,systemLog,gameState) ->
    if input? and systemLog? and gameState?
      console.log "SystemLogInspector: ",input.toJS(),systemLog.toJS(),gameState.toJS()

  @create: (div) ->
    return new @()

module.exports = SystemLogInspector
