EcsMachine = require '../../ecs/ecs_machine'
EntityStore = require '../../ecs/entity_store'
Systems = require '../systems'
SamusSystems = require '../entity/samus/systems'

ecsMachine = new EcsMachine(systems: [
  Systems.timer_system
  Systems.sound_system
  SamusSystems.powerup_collection
])

estore = new EntityStore()

# exports.initialState = ->

exports.update = (gameState,input) ->
  estore.restoreSnapshot(gameState)
  events = ecsMachine.update3(estore,input)
  return [estore.takeSnapshot(), events]

# exports.assetsToPreload = ->

# exports.spriteConfigs = ->
