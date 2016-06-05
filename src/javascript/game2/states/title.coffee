Immutable = require 'immutable'
{Map,List} = Immutable

C = require '../../components'
Systems = require '../systems'
EcsMachine = require '../../ecs2/ecs_machine'
EntityStore = require '../../ecs2/entity_store'

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
  return List([
    Map(type: 'graphic', name: 'images/main_title.png', file: 'images/main_title.png')
    Map(type: 'sound', name: 'main_title', file: 'sounds/music/main_title.mp3')
  ])

