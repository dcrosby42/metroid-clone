GameState = require './game_state'
Common = require '../entity/components'
General = require '../entity/general'
EcsMachine = require '../../ecs/ecs_machine'
EntityStore = require '../../ecs/entity_store'

CommonSystems = require '../systems'
SamusSystems = require '../entity/samus/systems'
SystemAccumulator = require '../../ecs/system_accumulator'

# RoomsLevel = require '../rooms_level'

class PowerupState extends GameState
  @StateName: 'powerup'

  constructor: (machine) ->
    super(machine)
    # @level = RoomsLevel
    @estore = new EntityStore()
    @ecsMachine = new EcsMachine(systems: @_getSystems())

  enter: (data=null,args=null) ->
    if !data?
      throw new Error("PowerupState requires game data to be provided on transition")

    @estore.restoreSnapshot(data)

  update: (gameInput) ->
    [@estore,events] = @ecsMachine.update(@estore,gameInput)
    events.forEach (e) => 
      @["event_#{e.get('name')}"]?(e)


  gameData: ->
    @estore.takeSnapshot()

  event_PowerupInstalled: (e) ->
    @transition 'adventure', @gameData()

  _getSystems: ->
    sys = new SystemAccumulator()
    sys.add CommonSystems, 'timer_system'
    sys.add SamusSystems, 'powerup_collection'
    return sys.systems

module.exports = PowerupState
