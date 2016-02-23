_ = require 'lodash'
Immutable = require 'immutable'

Enemies = require './entity/enemies'
EnemiesSystems =  require './entity/enemies/systems'

Doors = require './entity/doors'
DoorSystems =  require './entity/doors/systems'

Samus = require './entity/samus'
SamusSystems =  require './entity/samus/systems'

General = require './entity/general'
CommonSystems = require './systems'

Common = require './entity/components'

Items = require './entity/items'
SystemAccumulator = require '../ecs/system_accumulator'

RoomsLevel = {}


RoomsLevel.populateInitialEntities = (estore,params) ->
  # RNG
  estore.createEntity [
    Common.Name.merge(name: 'mainRandom')
    Common.Rng.merge(state: 123123123)
  ]
  
  # Samus start position
  brinstarEntrance = {x:648,y:191}
  nearBushTunnel = {x:1800,y:207}
  nearMorphBall = {x:400,y:175}
  samusStartPos = brinstarEntrance
  # samusStartPos = nearMorphBall
  # samusStartPos = nearBushTunnel
  estore.createEntity Samus.factory.createComponents('samus', position: samusStartPos)


  # HUD
  estore.createEntity [
    Common.Hud
    Common.Name.merge(name: 'hud')
    Common.Label.merge
      content: "E.?"
      layer: 'overlay'
    Common.Position.merge
      x: 25
      y: 35
  ]

  # XXX testing powerup placement
  # estore.createEntity Items.factory.createComponents('maru_mari', position: {x:360,y:152})

  # Viewport
  vpConf = Immutable.fromJS
    width:          16*16       # 16 tiles wide, 16 px per tile
    height:         15*16       # 15 tiles high, 16 px per tile
    trackBufLeft:   (8*18) - 16
    trackBufRight:  (8*18) + 16
    trackBufTop:    (8*18) - 16
    trackBufBottom: (8*18) + 16
  viewport = Common.Viewport.set('config', vpConf)
  estore.createEntity [
    Common.Name.merge(name: "Viewport")
    viewport
    Common.Position
  ]

  # RoomWatcher
  estore.createEntity [
    Common.Name.merge(name: "Room Watcher")
    Immutable.Map
      type: 'room_watcher'
      roomIds: Immutable.Set()
  ]

  # Background music
  estore.createEntity [
    Common.Name.merge(name: "BG Music")
    Immutable.Map
      type: 'background_music'
    Common.Sound.merge
      soundId: 'brinstar'
      volume: 1
      loop:true
      timeLimit: 110*1000
  ]

  estore


RoomsLevel.gameSystems = ->
  sys = new SystemAccumulator()
  sys.add CommonSystems, 'timer_system'
  sys.add CommonSystems, 'death_timer_system'
  sys.add CommonSystems, 'animation_timer_system'
  sys.add CommonSystems, 'sound_system'
  sys.add CommonSystems, 'controller_system'

  sys.add SamusSystems, 'samus_motion'

  sys.add SamusSystems, 'suit_control'
  sys.add SamusSystems, 'suit_velocity'
  sys.add SamusSystems, 'suit_sound'

  sys.add SamusSystems, 'morph_ball_control'
  sys.add SamusSystems, 'morph_ball_velocity'

  sys.add SamusSystems, 'samus_morph'

  sys.add EnemiesSystems, 'zoomer_controller_system'
  sys.add SamusSystems, 'short_beam'

  sys.add CommonSystems, 'samus_pickup_system'
  sys.add CommonSystems, 'samus_powerup_system'
  sys.add CommonSystems, 'samus_hit_system'
  sys.add CommonSystems, 'samus_damage_system'
  sys.add CommonSystems, 'samus_death_system'

  sys.add SamusSystems, 'samus_hud'
  sys.add EnemiesSystems, 'zoomer_crawl_system'
  sys.add CommonSystems, 'gravity_system'
  sys.add CommonSystems, 'map_physics_system'
  sys.add CommonSystems, 'map_ghost_system'
  sys.add CommonSystems, 'bullet_enemy_system'
  sys.add DoorSystems, 'bullet_door_system'
  sys.add CommonSystems, 'bullet_system'
  sys.add CommonSystems, 'enemy_hit_system'
  sys.add EnemiesSystems, 'skree_action'
  sys.add SamusSystems, 'suit_animation'
  sys.add SamusSystems, 'morph_ball_animation'
  sys.add CommonSystems, 'viewport_shuttle_system'
  sys.add CommonSystems, 'viewport_system'
  sys.add CommonSystems, 'viewport_room_system'
  sys.add CommonSystems, 'room_system'
  # sys.add CommonSystems, 'samus_room_system'

  sys.add DoorSystems, 'door_gel_system'
  return sys.systems

RoomsLevel.spriteConfigs = ->
  spriteConfigs = {}
  _.merge spriteConfigs, Samus.sprites
  _.merge spriteConfigs, Enemies.sprites
  _.merge spriteConfigs, General.sprites
  _.merge spriteConfigs, Doors.sprites
  _.merge spriteConfigs, Items.sprites
  spriteConfigs

RoomsLevel.graphicsToPreload = ->
  assets = [
    "images/brinstar.json"
  ]
  assets = assets.concat(Samus.assets)
  assets = assets.concat(Enemies.assets)
  assets = assets.concat(General.assets)
  assets = assets.concat(Doors.assets)
  assets = assets.concat(Items.assets)

  assets

RoomsLevel.soundsToPreload = ->
  songs = ["brinstar"]
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
  assets = {}
  for song in songs
    assets[song] = "sounds/music/#{song}.mp3"
  for effect in effects
    assets[effect] = "sounds/fx/#{effect}.wav"
  assets

module.exports = RoomsLevel

