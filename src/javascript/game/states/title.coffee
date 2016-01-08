GameState = require './game_state'

EcsMachine = require '../../ecs/ecs_machine'
EntityStore = require '../../ecs/entity_store'

MainTitleLevel = require '../main_title_level'

class TitleState extends GameState
  @StateName: 'title'

  constructor: (machine) ->
    super(machine)
    @level = MainTitleLevel
    @ecsMachine = new EcsMachine(systems: @level.gameSystems())

  enter: (data=null) ->
    @estore = new EntityStore()
    @level.populateInitialEntities(@estore)

  update: (gameInput) ->
    [@estore,events] = @ecsMachine.update(@estore,gameInput)
    events.forEach (e) => @["event_#{e.get('name')}"]?(e)

  gameData: ->
    @estore.takeSnapshot()

  event_StartNewGame: (e) ->
    # TODO?
    # data =
    #   zone: 'brinstar'
    #   pickups: []
    #   samus:
    #     energy: 30
    #     missiles: 0
    #     energyTanks: 0
    #     missileTanks: 0
    #     powerups: []
      
    # @transitionTo 'arrival', data # TODO?
    # @machine.transition 'adventure', data
    @transition 'adventure'


  event_ContinueGame: (e) ->
    @transition 'adventure'

module.exports = TitleState
