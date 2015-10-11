_ = require 'lodash'
Immutable = require 'immutable'

MapDatabase = require './map/map_database'

Enemies = require './entity/enemies'
EnemiesSystems =  require './entity/enemies/systems'

Doors = require './entity/doors'
DoorSystems =  require './entity/doors/systems'

Samus = require './entity/samus'
SamusSystems =  require './entity/samus/systems'

General = require './entity/general'
CommonSystems = require './systems'

Common = require './entity/components'

RoomsLevel = {}

RoomsLevel.populateInitialEntities = (estore) ->
  # Map
  # XXX
  # estore.createEntity [
  #   Common.Name.merge(name: 'Map')
  #   # Common.Map.set('name','areaA')
  #   Common.Map.merge(name: 'mapTest')
  # ]

  estore.createEntity Samus.factory.createComponents('samus', position: {x:780,y:50})

  # RNG
  estore.createEntity [
    Common.Name.merge(name: 'mainRandom')
    Common.Rng.merge(state: 123123123)
  ]

  # Samus status HUD
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

  # Viewport
  vpConf = Immutable.fromJS
    width:          16*16       # 16 tiles wide, 16 px per tile
    height:         15*16       # 15 tiles wide, 16 px per tile
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


  estore

class SystemAccumulator
  constructor: ->
    @systems = []
  add: (sysNs, name) ->
    if sysNs
      if system = sysNs[name]
        @systems.push system
      else
        console.log "!! No system '#{name}' found in namespace:",sysNs
        throw "No system '#{name}' found in namespace"
    else
      throw "Null namespace given when adding system named '#{name}"

RoomsLevel.gameSystems = ->
  sys = new SystemAccumulator()
  sys.add CommonSystems, 'timer_system'
  sys.add CommonSystems, 'death_timer_system'
  sys.add CommonSystems, 'animation_timer_system'
  sys.add CommonSystems, 'sound_system'
  sys.add SamusSystems, 'samus_motion'
  sys.add CommonSystems, 'controller_system'
  sys.add SamusSystems, 'samus_controller_action'
  sys.add EnemiesSystems, 'zoomer_controller_system'
  sys.add SamusSystems, 'short_beam_system'
  sys.add SamusSystems, 'samus_action_velocity'
  sys.add CommonSystems, 'samus_pickup_system'
  sys.add CommonSystems, 'samus_hit_system'
  sys.add CommonSystems, 'samus_damage_system'
  sys.add CommonSystems, 'samus_death_system'
  sys.add SamusSystems, 'samus_action_sounds'
  sys.add SamusSystems, 'samus_hud_system'
  sys.add EnemiesSystems, 'zoomer_crawl_system'
  sys.add CommonSystems, 'gravity_system'
  sys.add CommonSystems, 'map_physics_system'
  sys.add CommonSystems, 'map_ghost_system'
  sys.add CommonSystems, 'bullet_enemy_system'
  sys.add DoorSystems, 'bullet_door_system'
  sys.add CommonSystems, 'bullet_system'
  sys.add CommonSystems, 'enemy_hit_system'
  sys.add EnemiesSystems, 'skree_action'
  sys.add SamusSystems, 'samus_animation'
  sys.add CommonSystems, 'viewport_shuttle_system'
  sys.add CommonSystems, 'viewport_system'
  sys.add CommonSystems, 'viewport_room_system'
  sys.add CommonSystems, 'room_system'
  sys.add DoorSystems, 'door_gel_system'
  return sys.systems
  # [
  #   CommonSystems.timer_system
  #   CommonSystems.death_timer_system
  #   CommonSystems.animation_timer_system
  #   CommonSystems.sound_system
  #   SamusSystems.samus_motion
  #   CommonSystems.controller_system
  #   SamusSystems.samus_controller_action
  #   EnemiesSystems.zoomer_controller_system
  #   SamusSystems.short_beam_system
  #   SamusSystems.samus_action_velocity
  #   CommonSystems.samus_pickup_system
  #   CommonSystems.samus_hit_system
  #   CommonSystems.samus_damage_system
  #   CommonSystems.samus_death_system
  #   SamusSystems.samus_action_sounds
  #   SamusSystems.samus_hud_system
  #
  #   EnemiesSystems.zoomer_crawl_system
  #   CommonSystems.gravity_system
  #   CommonSystems.map_physics_system
  #   CommonSystems.map_ghost_system
  #   CommonSystems.bullet_enemy_system
  #   DoorSystems.bullet_door_system
  #   CommonSystems.bullet_system
  #   CommonSystems.enemy_hit_system
  #   EnemiesSystems.skree_action
  #   SamusSystems.samus_animation
  #   CommonSystems.viewport_shuttle_system
  #   CommonSystems.viewport_system
  #   CommonSystems.viewport_room_system
  #   CommonSystems.room_system
  #   DoorSystems.door_gel_system
  # ]

RoomsLevel.spriteConfigs = ->
  spriteConfigs = {}
  _.merge spriteConfigs, Samus.sprites
  _.merge spriteConfigs, Enemies.sprites
  _.merge spriteConfigs, General.sprites
  _.merge spriteConfigs, Doors.sprites
  spriteConfigs

_mapDb = MapDatabase.createDefault()
RoomsLevel.mapDatabase = ->
  _mapDb

RoomsLevel.graphicsToPreload = ->
  assets = [
    "images/brinstar.json"
  ]
  assets = assets.concat(Samus.assets)
  assets = assets.concat(Enemies.assets)
  assets = assets.concat(General.assets)
  assets = assets.concat(Doors.assets)

  assets

RoomsLevel.soundsToPreload = ->
  songs = ["brinstar"]
  effects = [
    "enemy_die1"
    "health"
    "step2"
    "jump"
    "samus_hurt"
    "samus_die"
    "short_beam"
    "door"
  ]
  assets = {}
  for song in songs
    assets[song] = "sounds/music/#{song}.mp3"
  for effect in effects
    assets[effect] = "sounds/fx/#{effect}.wav"
  assets

module.exports = RoomsLevel

