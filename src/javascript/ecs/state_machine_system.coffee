Immutable = require 'immutable'
BaseSystem = require './base_system'
StateMachine = require './state_machine2'

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
    @processStateMachine(@getEvents())

  processStateMachine: (events) ->
    s = @getProp(@_stateComponent,@_stateProperty)
    s1 = StateMachine.processEvents(@_stateMachine, s, events, @)
    unless s1 == s
      @setProp(@_stateComponent,@_stateProperty, s1)

  getEvents: ->
    # XXX: Don't generate events here, generate them somewhere else
    events = Immutable.List()
    if @get('controller').getIn(['states','action1Pressed'])
      events = events.push('triggerPulled')
    else if @get('controller').getIn(['states','action1'])
      events = events.push('triggerHeld')
    else if @get('controller').getIn(['states','action1Released'])
      events = events.push('triggerReleased')
    events = events.push('time')
    return events

module.exports = StateMachineSystem
