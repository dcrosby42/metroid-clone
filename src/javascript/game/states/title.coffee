GameState = require './game_state'

# _ = require 'lodash'
Immutable = require 'immutable'

# RoomsLevel = require './rooms_level'

# Enemies = require './entity/enemies'
# EnemiesSystems =  require './entity/enemies/systems'

Common = require '../entity/components'
# Samus = require './entity/samus'
# SamusSystems =  require './entity/samus/systems'

# General = require './entity/general'
CommonSystems = require '../systems'

EcsMachine = require '../../ecs/ecs_machine'
# EntityStore = require '../../ecs/entity_store'
EntityStore = require '../../ecs/entity_store2'

class TitleState extends GameState
  @StateName: 'title'

  @graphicsToPreload: ->
    assets = []
    assets.push("images/main_title.png")
    assets

  @soundsToPreload: ->
    songs = ["main_title"]
    effects = []
    assets = {}
    for song in songs
      assets[song] = "sounds/music/#{song}.mp3"
    for effect in effects
      assets[effect] = "sounds/fx/#{effect}.wav"
    assets

  constructor: (machine) ->
    super(machine)

    @ecsMachine = new EcsMachine
      systems: [
        CommonSystems.timer_system
        CommonSystems.death_timer_system
        CommonSystems.animation_timer_system
        CommonSystems.sound_system
        CommonSystems.controller_system
        CommonSystems.main_title_system
      ]

  enter: (data=null) ->
    @estore = new EntityStore()

    @estore.createEntity [
      Immutable.Map(
        type: 'main_title'
        state: 'begin'
      )
      Common.Controller.merge
        inputName: 'player1'
    ]

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
