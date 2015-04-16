Immutable = require 'immutable'

FilterExpander = require './filter_expander'

expandFilters = (system) ->
  path = ['config','filters']
  if system.hasIn path
    system.updateIn path, FilterExpander.expandFilters
  else
    system

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
  expandSystems: (systems) ->
    Immutable.fromJS(systems).map expandSystem
