Immutable = require 'immutable'
{Map,List} = Immutable
Comps = require '../entity/components'
Systems = require '../systems'
EcsMachine = require '../../ecs/ecs_machine'
EntityStore = require '../../ecs/entity_store'

# class Effect
#   constructor: (@kind) ->
#
# Effect.none = new Effect("None")

ecsMachine = new EcsMachine(systems: [
  Systems.timer_system
  Systems.death_timer_system
  Systems.animation_timer_system
  Systems.sound_system
  Systems.controller_system
  Systems.main_title_system
])


# (Model, Effects Action)
exports.initialState = () ->
  estore = new EntityStore()
  estore.createEntity [
    Immutable.Map(
      type: 'main_title'
      state: 'begin'
    )
    Comps.Controller.merge
      inputName: 'player1'
  ]
  return estore.takeSnapshot()

# Action -> Model -> (Model, Effects Action)
exports.update = (gameState,input) ->
  ecsMachine.update(gameState,input)

exports.assetsToPreload = ->
  return List([
    Map(type: 'graphic', name: 'images/main_title.png', file: 'images/main_title.png')
    Map(type: 'sound', name: 'main_title', file: 'sounds/music/main_title.mp3')
  ])
