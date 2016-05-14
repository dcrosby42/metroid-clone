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

estore = new EntityStore()

# (Model, Effects Action)
exports.initialState = () ->
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
  estore.restoreSnapshot(gameState)
  
  events = ecsMachine.update3(estore,input)

  return [estore.takeSnapshot(), events]

