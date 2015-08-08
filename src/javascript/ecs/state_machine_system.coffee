Immutable = require 'immutable'
BaseSystem = require './base_system'
StateMachine = require './state_machine'

class StateMachineSystem extends BaseSystem
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
    state = @getProp(@_stateComponent,@_stateProperty)
    
    # If defined, invoke the state handler, such as sleepState (for state 'sleep').
    # *State methods are best served by emitting events that can then be handled below.
    @[state+"State"]?()

    # Push events into the state machine and invoke associated actions:
    events = @getEvents(@getProp(@_stateComponent,'eid'))
    state1 = StateMachine.processEvents(@_stateMachine, state, events, @)

    # Update the approriate component with the resulting state:
    @setProp(@_stateComponent,@_stateProperty, state1) unless state1 == state

module.exports = StateMachineSystem
