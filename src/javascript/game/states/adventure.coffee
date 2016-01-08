GameState = require './game_state'

EcsMachine = require '../../ecs/ecs_machine'
EntityStore = require '../../ecs/entity_store'

RoomsLevel = require '../rooms_level'

class AdventureState extends GameState
  @StateName: 'adventure'

  constructor: (machine) ->
    super(machine)
    @level = RoomsLevel
    @ecsMachine = new EcsMachine(systems: @level.gameSystems())
    @estore = new EntityStore()

  enter: (data=null) ->
    @estore = new EntityStore()
    @level.populateInitialEntities(@estore)

  update: (gameInput) ->
    [@estore,events] = @ecsMachine.update(@estore,gameInput)
    events.forEach (e) => @["event_#{e.get('name')}"]?(e)

  gameData: ->
    @estore.takeSnapshot()

  event_Killed: (e) ->
    @transition 'title'

module.exports = AdventureState