_ = require 'lodash'

C = require '../../components'
Systems = require '../systems'
EcsMachine = require '../../ecs2/ecs_machine'
EntityStore = require '../../ecs2/entity_store'

window.C = C # WINDOWDEBUG
window.T = C.Types #WINDOWDEBUG

General =  require '../../game/entity/general'


ecsMachine = new EcsMachine([
  Systems.timer_system()
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
  assets = []
  for fname in General.assets
    assets.push {type:'graphic', name: fname, file: fname}

  # assets = assets.concat [
    # {type:'sound', name: 'some_music', file: 'sounds/music/some_music.mp3'}
    # {type:'sound', name: 'noise', file: 'sounds/fx/noise.wav'}
  # ]

  assets = assets.concat [
    {type: 'data', name: 'world_map', file: 'data/world_map.json'}
  ]
  
  return assets

exports.spriteConfigs = ->
  cfgs = {}
  _.merge cfgs, General.sprites
  cfgs

