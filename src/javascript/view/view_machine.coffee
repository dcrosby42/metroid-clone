# EntityStore  = require '../ecs/entity_store'
EntityStore  = require '../ecs/entity_store2'

class ViewMachine
  constructor: ({@systems, @uiState, @uiConfig}) ->
    @estore = new EntityStore()

  # TODO: ? accept "ui state" as a paramter instead of using ViewMachine itself?
  # update: (estore) ->
  #   @systems.forEach (system) =>
  #     system.update(@uiState, estore, @uiConfig)
  #   #TODO: ? return [uiState, events] ??

  update2: (gameState) ->
    @estore.restoreSnapshot(gameState)
    @systems.forEach (system) =>
      system.update(@uiState, @estore, @uiConfig)



module.exports = ViewMachine

