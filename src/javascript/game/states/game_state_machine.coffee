Immutable = require 'immutable'

class GameStateMachine
  constructor: (stateClasses) ->
    states = Immutable.List(stateClasses).map (c) => new c(@)

    @stateMap = states.reduce (map,state) ->
      map.set(state.stateName(), state)
    , Immutable.Map()

    @transitionToState states.first()
      
  transition: (stateName,data=null,args=null) ->
    console.log "GameStateMachine.transition stateName=#{stateName} data? #{data?} args? #{args?}"
    state = @stateMap.get(stateName)
    if state?
      @transitionToState state,data,args
    else
      throw new Error("No state defined for '#{stateName}'; valid state names: #{@stateMap.keySeq().toJS().toString()}")

  transitionToState: (nextState,data=null,args=null) ->
    if @currentState?
      prevState = @currentState
      prevState.exit?()
    nextState.enter?(data,args)
    @currentState = nextState
    null

  update: (params...) ->
    @currentState.update(params...)
    return @currentState.gameData()
    
module.exports = GameStateMachine
