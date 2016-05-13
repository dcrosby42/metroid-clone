Immutable = require 'immutable'
Comps = require '../entity/components'

Systems = require '../systems'
SamusSystems =  require '../entity/samus/systems'
EnemiesSystems =  require '../entity/enemies/systems'
DoorSystems =  require '../entity/doors/systems'

EcsMachine = require '../../ecs/ecs_machine'
EntityStore = require '../../ecs/entity_store'

Samus = require '../entity/samus'

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
  samusStartPos = shaft1
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

  # events.forEach (e) ->
  #   switch e.get('name')
  #     when ''
  return [estore.takeSnapshot(), events]
  
