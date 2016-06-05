BaseSystem = require './base_system'
# C = require '../components'
# T = C.Types
StateMachine = require './state_machine'
Immutable = require 'immutable'

class StateMachineSystem extends BaseSystem
  # @StateMachine:
  #   componentProperty: ['UNSET_COMPONENT_NAME', 'UNSET_PROPERTY_NAME']
  #   start: 'default'
  #   states:
  #     default:
  #       events:
  #         time:
  #           nextState: 'default'

  constructor: ->
    super()
    if !@constructor.StateMachine?
      console.log "!! StateMachineSystem: #{@constructor.name} doesn't have a @StateMachine declaration"
    if !@constructor.StateMachine.componentProperty?
      console.log "!! StateMachineSystem: #{@constructor.name} StateMachine.componentProperty required"
    [@_stateComponentType, @_stateProperty] = @constructor.StateMachine.componentProperty
    @_stateMachine = Immutable.fromJS(@constructor.StateMachine)

  process: (r) ->
    @entity = r.entity
    @eid = @entity.eid

    # determine current state
    comp = r.comps[@_stateComponentType]
    state = comp[@_stateProperty] || @_stateMachine.get('start')
    
    @[state+"State"]?() # eg, sleepState() for state='sleep', if the method exists

    events = @getEvents(@eid)

    state1 = StateMachine.processEvents(@_stateMachine, state, events, @)

    comp[@_stateProperty] = state1

module.exports = StateMachineSystem
