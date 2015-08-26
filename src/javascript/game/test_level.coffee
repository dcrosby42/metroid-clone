_ = require 'lodash'
Immutable = require 'immutable'

MapDatabase = require './map/map_database'

Enemies = require './entity/enemies'
EnemiesSystems =  require './entity/enemies/systems'

Samus = require './entity/samus'
SamusSystems =  require './entity/samus/systems'

General = require './entity/general'
CommonSystems = require './systems'

Common = require './entity/components'

TestLevel = {}

TestLevel.populateInitialEntities = (estore) ->
  # Map
  estore.createEntity [
    # Common.Map.set('name','areaA')
    Common.Map.set('name','mapTest')
  ]

  estore.createEntity Samus.factory.createComponents('samus')

  # Skrees:
  for x in [150, 200, 250, 300, 350]
    estore.createEntity Enemies.factory.createComponents('basicSkree', x:x, y: 32)

  # Zoomers:
  x = 100
  y = 95
  zoomerComps = Enemies.factory.createComponents('basicZoomer', x:x, y:y)
  zoomerComps.push Common.Controller.merge(inputName: 'debug1')
  estore.createEntity zoomerComps

  x = 150
  y = 151
  zoomerComps2 = Enemies.factory.createComponents('basicZoomer', x:x, y:y)
  estore.createEntity zoomerComps2

  estore

TestLevel.gameSystems = ->
  [
    CommonSystems.timer_system
    CommonSystems.death_timer_system
    CommonSystems.visual_timer_system
    CommonSystems.sound_system
    SamusSystems.samus_motion
    CommonSystems.controller_system
    SamusSystems.samus_controller_action
    EnemiesSystems.zoomer_controller_system
    SamusSystems.short_beam_system
    SamusSystems.samus_action_velocity
    CommonSystems.samus_hit_system
    CommonSystems.samus_damage_system
    CommonSystems.samus_death_system
    SamusSystems.samus_action_sounds

    EnemiesSystems.zoomer_crawl_system
    CommonSystems.gravity_system
    CommonSystems.map_physics_system
    CommonSystems.map_ghost_system
    CommonSystems.bullet_enemy_system
    CommonSystems.bullet_system
    CommonSystems.enemy_hit_system
    EnemiesSystems.skree_action
    SamusSystems.samus_animation
  ]

TestLevel.spriteConfigs = ->
  spriteConfigs = {}
  _.merge spriteConfigs, Samus.sprites
  _.merge spriteConfigs, Enemies.sprites
  _.merge spriteConfigs, General.sprites
  spriteConfigs

_mapDb = MapDatabase.createDefault()
TestLevel.mapDatabase = ->
  _mapDb

TestLevel.graphicsToPreload = ->
  assets = [
    "images/brinstar.json"
  ]
  assets = assets.concat(Samus.assets)
  assets = assets.concat(Enemies.assets)
  assets = assets.concat(General.assets)

  assets

TestLevel.soundsToPreload = ->
  songs = ["brinstar"]
  effects = [
    "enemy_die1"
    "health"
    "step2"
    "jump"
    "samus_hurt"
    "samus_die"
    "short_beam"
  ]
  assets = {}
  for song in songs
    assets[song] = "sounds/music/#{song}.mp3"
  for effect in effects
    assets[effect] = "sounds/fx/#{effect}.wav"
  assets

module.exports = TestLevel

