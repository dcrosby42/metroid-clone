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
  @ImplyEntityNum: 0

  constructor: ->
    super()
    if !@constructor.StateMachine?
      console.log "!! StateMachineSystem: #{@constructor.name} doesn't have a @StateMachine declaration"
    if !@constructor.StateMachine.componentProperty?
      console.log "!! StateMachineSystem: #{@constructor.name} StateMachine.componentProperty required"
    [@_stateComponentType, @_stateProperty] = @constructor.StateMachine.componentProperty
    @_stateMachine = Immutable.fromJS(@constructor.StateMachine)

    if @constructor.Subscribe[0] instanceof Array
      @isCompound = true
      @implyEntityNum = @constructor.ImplyEntityNum

  process: (args...) ->
    if @isCompound
      @rList = args
      @r = @rList[@implyEntityNum]
    else
      @r = args[0]
    @entity = @r.entity
    @eid = @entity.eid
    @comps = @r.comps

    # determine current state
    comp = @comps[@_stateComponentType]
    state = comp[@_stateProperty] || @_stateMachine.get('start')
    
    @[state+"State"]?() # eg, sleepState() for state='sleep', if the method exists

    events = @getEvents(@eid)

    state1 = StateMachine.processEvents(@_stateMachine, state, events, @)

    comp[@_stateProperty] = state1

module.exports = StateMachineSystem
