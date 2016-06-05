EntityStore  = require '../ecs2/entity_store'

class ViewMachine
  constructor: ({@systems, @uiState, @uiConfig}) ->
    # @estore = new EntityStore()

  update: (estore) ->
    for system in @systems
      system.update(@uiState, estore, @uiConfig)

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

