Immutable = require 'immutable'
BaseSystem = require './base_system'
StateMachine = require './state_machine'

class StateMachineSystem extends BaseSystem
  @SystemType: 'StateMachineSystem'

  @StateMachine:
    componentProperty: ['UNSET_COMPONENT_NAME', 'UNSET_PROPERTY_NAME']
    start: 'default'
    states:
      default:
        events:
          time:
            nextState: 'default'

  constructor: ->
    super()
    [@_stateComponent, @_stateProperty] = @constructor.StateMachine.componentProperty
    @_stateMachine = Immutable.fromJS(@constructor.StateMachine)

  process: ->
    @processStateMachine(@getEvents(@getProp(@_stateComponent,'eid')))

  processStateMachine: (events) ->
    s = @getProp(@_stateComponent,@_stateProperty)
    s1 = StateMachine.processEvents(@_stateMachine, s, events, @)
    unless s1 == s
      @setProp(@_stateComponent,@_stateProperty, s1)

module.exports = StateMachineSystem
