GameState = require './game_state'

EcsMachine = require '../../ecs/ecs_machine'
EntityStore = require '../../ecs/entity_store'
FilterExpander = require '../../ecs/filter_expander'

RoomsLevel = require '../rooms_level'
General = require '../entity/general'

bgMusicFilter = FilterExpander.expandFilterGroups(['background_music'])

class AdventureState extends GameState
  @StateName: 'adventure'

  constructor: (machine) ->
    super(machine)
    @level = RoomsLevel
    @ecsMachine = new EcsMachine(systems: @level.gameSystems())
    @estore = new EntityStore()

  enter: (data=null) ->
    @estore = new EntityStore()
    if data == null
      @level.populateInitialEntities(@estore)
    else
      @estore.restoreSnapshot(data)

    @_stopMusic()
    @_startMusic()

  update: (gameInput) ->
    [@estore,events] = @ecsMachine.update(@estore,gameInput)
    events.forEach (e) => @["event_#{e.get('name')}"]?(e)

  gameData: ->
    @estore.takeSnapshot()

  event_Killed: (e) ->
    @transition 'title'

  event_PowerupTouched: (e) ->
    @_stopMusic()
    @transition 'powerup', @gameData()

  _startMusic: ->
    @estore.createEntity General.factory.createComponents(
      'backgroundMusic',
      music: 'brinstar'
      volume: 1
      timeLimit: '110*1000'
    )
    
  _stopMusic: ->
    @estore.search(bgMusicFilter).forEach (comps) =>
      eid = comps.getIn(['background_music','eid'])
      @estore.destroyEntity(eid)

module.exports = AdventureState
