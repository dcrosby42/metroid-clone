EcsMachine = require '../../ecs/ecs_machine'
EntityStore = require '../../ecs/entity_store'
Systems = require '../systems'
SamusSystems = require '../entity/samus/systems'

ecsMachine = new EcsMachine(systems: [
  Systems.timer_system
  Systems.sound_system
  SamusSystems.powerup_collection
])

# exports.initialState = ->

exports.update = (gameState,input) ->
  ecsMachine.update(gameState,input)

# exports.assetsToPreload = ->

# exports.spriteConfigs = ->
