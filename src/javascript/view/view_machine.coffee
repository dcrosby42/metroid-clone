EntityStore  = require '../ecs/entity_store'

class ViewMachine
  constructor: ({@systems, @uiState, @uiConfig}) ->
    @estore = new EntityStore()

  update: (gameState) ->
    @estore.restoreSnapshot(gameState)
    @systems.forEach (system) =>
      system.update(@uiState, @estore, @uiConfig)

  setMute: (m) ->
    if m
      @uiState.muteAudio()
    else
      @uiState.unmuteAudio()

  setDrawHitBoxes: (d) ->
    @uiState.drawHitBoxes = d



module.exports = ViewMachine

