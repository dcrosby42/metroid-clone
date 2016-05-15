Immutable = require 'immutable'
{Map,List}=Immutable
Comps = require '../entity/components'

Systems = require '../systems'
SamusSystems =  require '../entity/samus/systems'
EnemiesSystems =  require '../entity/enemies/systems'
DoorSystems =  require '../entity/doors/systems'

EcsMachine = require '../../ecs/ecs_machine'
EntityStore = require '../../ecs/entity_store'

Samus = require '../entity/samus'
Enemies =  require '../entity/enemies'
Doors =  require '../entity/doors'
General =  require '../entity/general'
Items =  require '../entity/items'

ecsMachine = new EcsMachine(systems: [
    Systems.timer_system
    Systems.death_timer_system
    Systems.animation_timer_system
    Systems.sound_system
    Systems.controller_system

    SamusSystems.samus_motion

    SamusSystems.suit_control
    SamusSystems.suit_velocity
    SamusSystems.suit_sound

    SamusSystems.morph_ball_control
    SamusSystems.morph_ball_velocity

    SamusSystems.samus_morph

    EnemiesSystems.zoomer_controller_system
    SamusSystems.short_beam

    Systems.samus_pickup_system
    Systems.samus_powerup_system
    Systems.samus_hit_system
    Systems.samus_damage_system
    Systems.samus_death_system

    SamusSystems.samus_hud
    EnemiesSystems.zoomer_crawl_system
    Systems.gravity_system
    Systems.map_physics_system
    Systems.map_ghost_system
    Systems.bullet_enemy_system
    DoorSystems.bullet_door_system
    Systems.bullet_system
    Systems.enemy_hit_system
    EnemiesSystems.skree_action
    SamusSystems.suit_animation
    SamusSystems.morph_ball_animation
    Systems.viewport_shuttle_system
    Systems.viewport_system
    Systems.viewport_room_system
    Systems.room_system
    DoorSystems.door_gel_system
])

estore = new EntityStore()

exports.initialState = () ->
  # RNG
  estore.createEntity [
    Comps.Name.merge(name: 'mainRandom')
    Comps.Rng.merge(state: 123123123)
  ]
  
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
  estore.createEntity Samus.factory.createComponents('samus', position: samusStartPos)


  # HUD
  estore.createEntity [
    Comps.Hud
    Comps.Name.merge(name: 'hud')
    Comps.Label.merge
      content: "E.?"
      layer: 'overlay'
    Comps.Position.merge
      x: 25
      y: 35
  ]

  # XXX testing powerup placement
  # estore.createEntity Items.factory.createComponents('maru_mari', position: {x:360,y:152})
 
  # Items
  estore.createEntity [
    Comps.Name.merge(name: 'Collected Items')
    Immutable.Map
      type: 'collected_items'
      itemIds: Immutable.Set()
  ]

  # Viewport
  vpConf = Immutable.fromJS
    width:          16*16       # 16 tiles wide, 16 px per tile
    height:         15*16       # 15 tiles high, 16 px per tile
    trackBufLeft:   (8*18) - 16
    trackBufRight:  (8*18) + 16
    trackBufTop:    (8*18) - 16
    trackBufBottom: (8*18) + 16
  viewport = Comps.Viewport.set('config', vpConf)
  estore.createEntity [
    Comps.Name.merge(name: "Viewport")
    viewport
    Comps.Position
  ]

  # RoomWatcher
  estore.createEntity [
    Comps.Name.merge(name: "Room Watcher")
    Immutable.Map
      type: 'room_watcher'
      roomIds: Immutable.Set()
  ]
  return estore.takeSnapshot()

exports.update = (gameState,input) ->
  estore.restoreSnapshot(gameState)
  events = ecsMachine.update3(estore,input)
  return [estore.takeSnapshot(), events]

exports.assetsToPreload = ->
  graphics = List(
    [ "images/brinstar.json" ]
      .concat(Samus.assets)
      .concat(Enemies.assets)
      .concat(General.assets)
      .concat(Doors.assets)
      .concat(Items.assets))
    .map (fname) ->
      Map(type:'graphic', name:fname, file:fname)

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
  _.merge cfgs, Samus.sprites
  _.merge cfgs, Enemies.sprites
  _.merge cfgs, General.sprites
  _.merge cfgs, Doors.sprites
  _.merge cfgs, Items.sprites
  cfgs
  

