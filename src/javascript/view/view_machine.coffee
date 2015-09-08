class ViewMachine
  constructor: ({@systems, @uiState, @uiConfig}) ->

  # TODO: ? accept "ui state" as a paramter instead of using ViewMachine itself?
  update: (estore) ->
    @systems.forEach (system) =>
      system.update(@uiState, estore, @uiConfig)
    #TODO: ? return [uiState, events] ??

module.exports = ViewMachine

