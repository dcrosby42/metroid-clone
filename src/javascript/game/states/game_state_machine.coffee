Immutable = require 'immutable'

class GameStateMachine
  constructor: (stateClasses) ->
    states = Immutable.List(stateClasses).map (c) => new c(@)

    @stateMap = states.reduce (map,state) ->
      map.set(state.stateName(), state)
    , Immutable.Map()

    @transitionToState states.first()
      
  transition: (stateName,data=null) ->
    @transitionToState @stateMap.get(stateName,data)

  transitionToState: (nextState,data=null) ->
    if @currentState?
      prevState = @currentState
      prevState.exit?()
    nextState.enter?(data)
    @currentState = nextState
    null

  update: (params...) ->
    @currentState.update(params...)
    return @currentState.gameData()
    
module.exports = GameStateMachine
