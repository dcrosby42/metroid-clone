class OutputSystemRunner
  constructor: ({@entityFinder, @ui, @systems}) ->
    @updateFns = @systems.map (s) -> s.get('update')

  run: (input) ->
    @updateFns.forEach (system) =>
      system.run @entityFinder, @input, @ui


