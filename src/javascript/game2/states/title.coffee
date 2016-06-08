_ = require 'lodash'
Immutable = require 'immutable'
{Map,List} = Immutable

C = require '../../components'
Systems = require '../systems'
EcsMachine = require '../../ecs2/ecs_machine'
EntityStore = require '../../ecs2/entity_store'

# XXX
window.C = C
window.T = C.Types

General =  require '../../game/entity/general'

# class Effect
#   constructor: (@kind) ->
#
# Effect.none = new Effect("None")

ecsMachine = new EcsMachine([
  Systems.timer_system()
  # Systems.death_timer_system()
  Systems.animation_timer_system()
  # Systems.sound_system() # TODO
  Systems.controller_system()
  Systems.main_title_system()
])


# (Model, Effects Action)
exports.initialState = () ->
  estore = new EntityStore()

  mainTitle = C.MainTitle.default()
  controller = C.Controller.default()
  controller.inputName = 'player1'
  estore.createEntity [
    mainTitle
    controller
  ]

  estore

# Action -> Model -> (Model, Effects Action)
exports.update = (gameState,input) ->
  ecsMachine.update(gameState,input)

exports.assetsToPreload = ->
  # return List([
  #   Map(type: 'graphic', name: 'images/main_title.png', file: 'images/main_title.png')
  #   Map(type: 'sound', name: 'main_title', file: 'sounds/music/main_title.mp3')
  # ])
  graphics = List(
    [ ]
      .concat(General.assets)
      # .concat(Samus.assets)
      # .concat(Enemies.assets)
      # .concat(Doors.assets)
      # .concat(Items.assets)
    )
    .map (fname) ->
      Map(type:'graphic', name:fname, file:fname)

  songs = [
    # "main title theme TODO"
    # "brinstar"
    # "powerup_jingle"
  ]
  effects = [
    # "enemy_die1"
    # "health"
    # "step"
    # "step2"
    # "jump"
    # "samus_hurt"
    # "samus_die"
    # "short_beam"
    # "door"
    # "samus_morphball"
    # "rocket_shot"
  ]

  sounds = List()
  for song in songs
    sounds = sounds.push Map(type: 'sound', name: song, file: "sounds/music/#{song}.mp3")
  for effect in effects
    sounds = sounds.push Map(type: 'sound', name: effect, file: "sounds/fx/#{effect}.wav")
  
  data = List([
    Map(type: 'data', name: 'world_map', file: 'data/world_map.json')
  ])

  return graphics
    .concat(sounds)
    .concat(data)

exports.spriteConfigs = ->
  cfgs = {}
  _.merge cfgs, General.sprites
  cfgs

