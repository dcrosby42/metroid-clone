_ = require 'lodash'
Immutable = require 'immutable'

TestLevel = require './test_level'

Enemies = require './entity/enemies'
EnemiesSystems =  require './entity/enemies/systems'

Common = require './entity/components'
Samus = require './entity/samus'
SamusSystems =  require './entity/samus/systems'

General = require './entity/general'
General = require './entity/general'
CommonSystems = require './systems'

L = {}

L.populateInitialEntities = (estore) ->

  estore.createEntity [
    Immutable.Map(
      type: 'main_title'
      state: 'begin'
    )
    Common.Controller.merge
      inputName: 'player1'

    # Common.Visual.merge
    #   layer: 'background'
    #   spriteName: 'main_title'
    #   state: 'start'

  ]

  # estore.createEntity [
  #   Common.Label.merge
  #     content: "PUSH START BUTTON"
  #     layer: 'overlay'
  #   Common.Position.merge
  #     x: 50
  #     y: 50
  # ]

  # estore.createEntity [
  #   Common.Sound.merge
  #     soundId: 'main_title'
  #     timeLimit: 102 * 1000
  #     volume: 0.3
  # ]

  estore

L.gameSystems = ->
  [
    CommonSystems.timer_system
    CommonSystems.death_timer_system
    CommonSystems.visual_timer_system
    CommonSystems.sound_system
    # SamusSystems.samus_motion
    CommonSystems.controller_system
    CommonSystems.main_title_system
    # EnemiesSystems.zoomer_controller_system # XXX
    # EnemiesSystems.zoomer_crawl_system
    # SamusSystems.samus_controller_action
    # SamusSystems.short_beam_system
    # SamusSystems.samus_action_velocity
    # CommonSystems.samus_hit_system
    # CommonSystems.samus_damage_system
    # SamusSystems.samus_action_sounds
    # CommonSystems.gravity_system
    # CommonSystems.map_physics_system
    # CommonSystems.map_ghost_system
    # CommonSystems.bullet_enemy_system
    # CommonSystems.bullet_system
    # CommonSystems.enemy_hit_system
    # EnemiesSystems.skree_action
    # SamusSystems.samus_animation
  ]

L.spriteConfigs = ->
  TestLevel.spriteConfigs()

L.mapDatabase = ->
  null
  #TestLevel.mapDatabase()

L.graphicsToPreload = ->
  # assets = TestLevel.graphicsToPreload()
  assets = []
  assets.push("images/main_title.png")
  # assets.push("fonts/narpassword00000_regular_20.fnt")
  # assets.push("fonts/narpassword00000_regular_20.png")
  assets

L.soundsToPreload = ->
  # TestLevel.soundsToPreload()
  songs = ["main_title"]
  effects = []

  assets = {}
  for song in songs
    assets[song] = "sounds/music/#{song}.mp3"
  for effect in effects
    assets[effect] = "sounds/fx/#{effect}.wav"

  assets

module.exports = L

