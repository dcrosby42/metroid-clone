class GameState
  @StateName: '_unnamed_state_'
  
  stateName: -> @constructor.StateName
  @stateName: -> @StateName

  constructor: (@machine) ->

  enter: (data=null) ->

  exit: ->

  update: (gameInput) ->

  transition: (stateName) ->
    @machine.transition(stateName)

  gameData: ->
    throw new Error("GameState #{@stateName} doesn't implement method gameData()")

module.exports = GameState
