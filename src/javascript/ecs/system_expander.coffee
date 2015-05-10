Immutable = require 'immutable'
FilterExpander = require './filter_expander'
StateMachine = require './state_machine'

expandFilters = (system) ->
  path = ['config','filters']
  if system.hasIn path
    system.updateIn path, FilterExpander.expandFilterGroups
  else
    system

expandType = (system) ->
  if system.has 'type'
    system
  else
    system.set 'type', 'iterating-updating'

expandStateMachine = (system) ->
  fsm = system.get('fsm')
  if fsm?
    updateFsm = (comps,input,u) -> StateMachine.update(fsm, comps, input, u)
    system.set('update', updateFsm)
  else
    system

expandSystem = (system) ->
  if system?
    expandStateMachine(
      expandFilters(
        expandType(
          system)))
  else
    console.log "!! SystemExpander.expandSystem invoked with null or undefined system"

module.exports =
  expandSystem: (system) ->
    expandSystem(Immutable.fromJS(system))
  expandSystems: (systems) ->
    Immutable.fromJS(systems).map expandSystem



