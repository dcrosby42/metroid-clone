EntityStore  = require '../ecs/entity_store'

class ViewMachine
  constructor: ({@systems, @uiState, @uiConfig}) ->
    @estore = new EntityStore()

  update: (gameState) ->
    @estore.restoreSnapshot(gameState)
    @_callSystems()
    # @systems.forEach (system) =>
    #   system.update(@uiState, @estore, @uiConfig)

  _callSystems: ->
    @systems.forEach (system) =>
      system.update(@uiState, @estore, @uiConfig)

  setMute: (m) ->
    return if m == @_mute
    @_mute = m
    if @_mute
      @uiState.muteAudio()
    else
      @uiState.unmuteAudio()
    @_callSystems()

  setDrawHitBoxes: (d) ->
    return if d == @_dhb
    @_dhb = d
    @uiState.drawHitBoxes = @_dhb
    @_callSystems()



module.exports = ViewMachine

