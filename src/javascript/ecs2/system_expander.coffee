Immutable = require 'immutable'

FilterExpander = require './filter_expander'

expandFilters = (system) ->
  system.updateIn ['config','filters'], FilterExpander.expandFilters

expandType = (system) ->
  if system.has 'type'
    system
  else
    system.set 'type', 'iterating-updating'

expandSystem = (system) ->
  expandFilters(
    expandType(
      system))

module.exports =
  expandSystem: (system) ->
    expandSystem(Immutable.fromJS(system))
