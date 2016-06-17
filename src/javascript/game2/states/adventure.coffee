_ = require 'lodash'
# Immutable = require 'immutable'
# {Map,List}=Immutable
# Comps = require '../entity/components'
C = require '../../components'
T = C.Types
Systems = require '../systems'
EcsMachine = require '../../ecs2/ecs_machine'
EntityStore = require '../../ecs2/entity_store'

Prefab = require '../prefab'

# SamusSystems =  require '../entity/samus/systems'
# EnemiesSystems =  require '../entity/enemies/systems'
# DoorSystems =  require '../entity/doors/systems'
#
Samus = require '../../game/entity/samus'
Enemies =  require '../../game/entity/enemies'
Doors =  require '../../game/entity/doors'
General =  require '../../game/entity/general'
Items =  require '../../game/entity/items'

ecsMachine = new EcsMachine([
    Systems.timer_system()
    Systems.expire_system()
    Systems.animation_timer_system()
    Systems.sound_system()
    Systems.controller_system()

    Systems.motion_system()
    
    Systems.suit_control_system()
    Systems.suit_velocity_system()
    Systems.suit_sound_system()
    
    # SamusSystems.morph_ball_control
    # SamusSystems.morph_ball_velocity
   
    # SamusSystems.samus_morph
  
    # # dev only: EnemiesSystems.zoomer_controller_system
    Systems.weapons_system() # SamusSystems.weapons_system
    Systems.short_beam_system()# SamusSystems.short_beam
    # SamusSystems.missile_launcher_system
 
    # Systems.samus_pickup_system
    # Systems.samus_hit_system
    # Systems.samus_damage_system
    # Systems.samus_death_system
    #
    Systems.hud_system()
    Systems.zoomer_crawl_system() # EnemiesSystems.zoomer_crawl_system
    Systems.gravity_system()
    Systems.map_physics_system()
    Systems.map_ghost_system()
    Systems.bullet_enemy_system()
    # Systems.missile_enemy_system
    # DoorSystems.bullet_door_system
    # DoorSystems.missile_door_system
    Systems.bullet_system()
    # Systems.missile_system
    Systems.enemy_hit_system()
    #
    Systems.skree_action_system() # EnemiesSystems.skree_action
    Systems.suit_animation_system() # TODO SamusSystems.suit_animation
    # SamusSystems.morph_ball_animation
    Systems.viewport_shuttle_system()
    Systems.viewport_system()
    Systems.viewport_room_system()
    Systems.room_system()
    # DoorSystems.door_gel_system
])


exports.initialState = () ->
  estore = new EntityStore()

  # RNG
  estore.createEntity(Prefab.rng())
  
  # Samus start position
  # brinstarEntrance = {x:648,y:191}
  brinstarEntrance = {x:648,y:191+(13*240)}
  shaft1 = {x:2600, y:3247}
  # nearMorphBall = {x:400,y:175}
  # onBridge = {x:1466,y:95}
  # samusStartPos = brinstarEntrance
  samusStartPos = brinstarEntrance
  # samusStartPos = nearMorphBall
  # samusStartPos = onBridge

  samus = estore.createEntity(Prefab.samus())
  samusPos = samus.get(T.Position)
  samusPos.x = samusStartPos.x
  samusPos.y = samusStartPos.y

  # estore.createEntity Samus.factory.createComponents('samus', position: samusStartPos)


  # HUD
  estore.createEntity Prefab.hud()

# Items
  estore.createEntity Prefab.collectedItems()

  # Viewport
  estore.createEntity Prefab.viewport()

  # RoomWatcher
  estore.createEntity Prefab.roomWatcher()

  estore


exports.update = (gameState,input) ->
  ecsMachine.update(gameState,input)

exports.assetsToPreload = ->
  assets = []
  gfx = [ "images/brinstar.json" ]
      .concat(Samus.assets)
      .concat(Enemies.assets)
      .concat(General.assets)
      .concat(Doors.assets)
      .concat(Items.assets)
  for fname in gfx
    assets.push { type: "graphic", name: fname, file: fname }

  songs = [
    "brinstar"
    "powerup_jingle"
  ]
  effects = [
    "enemy_die1"
    "health"
    "step"
    "step2"
    "jump"
    "samus_hurt"
    "samus_die"
    "short_beam"
    "door"
    "samus_morphball"
    "rocket_shot"
  ]

  for song in songs
    assets.push {type: 'sound', name: song, file: "sounds/music/#{song}.mp3"}
  for effect in effects
    assets.push {type: 'sound', name: effect, file: "sounds/fx/#{effect}.wav"}
  

  assets.push {type: 'data', name: 'world_map', file: 'data/world_map.json'}

  assets

exports.spriteConfigs = ->
  cfgs = {}
  _.merge cfgs, Samus.sprites
  _.merge cfgs, Enemies.sprites
  _.merge cfgs, General.sprites
  _.merge cfgs, Doors.sprites
  _.merge cfgs, Items.sprites
  cfgs
  

# console.log exports.spriteConfigs()

