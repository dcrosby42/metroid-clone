Immutable = require 'immutable'

class OutputSystemRunner
  constructor: ({@entityFinder, @ui, systems}) ->
    @systems = Immutable.fromJS(systems)
    @updateFns = @systems.map (s) -> s.get('update')

  run: (input) ->
    @updateFns.forEach (fn) =>
      fn @entityFinder, input, @ui



module.exports = OutputSystemRunner

