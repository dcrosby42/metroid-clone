C = require '../../components'
T = C.Types
Systems = require '../systems'
EcsMachine = require '../../ecs2/ecs_machine'
EntityStore = require '../../ecs2/entity_store'


ecsMachine = new EcsMachine([
  Systems.timer_system()
  Systems.sound_system()
  Systems.powerup_collection_system()
])

# don't really use this... this module operates on state from the adventure module
exports.initialState = ->
  estore = new EntityStore()
  

exports.update = (gameState,input) ->
  ecsMachine.update(gameState,input)

exports.assetsToPreload = ->
  [
    {type: 'sound', name: 'powerup_jingle', file: 'sounds/music/powerup_jingle.mp3' }
  ]

# exports.spriteConfigs = ->
