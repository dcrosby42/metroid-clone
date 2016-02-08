_ = require 'lodash'
Immutable = require 'immutable'

TestLevel = require './rooms_level' # XXX yuck

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
    Immutable.fromJS(type: "map", name: "zoomerTest")
  ]

  # estore.createEntity Samus.factory.createComponents('samus')
  x = 100
  # y = 103.5
  y = 95
  zoomerComps = Enemies.factory.createComponents('basicZoomer', x:x, y:y)
  zoomerComps.push Common.Controller.merge(inputName: 'debug1')
  estore.createEntity zoomerComps

  x = 150
  y = 151
  zoomerComps2 = Enemies.factory.createComponents('basicZoomer', x:x, y:y)
  estore.createEntity zoomerComps2

  # estore.createEntity Samus.factory.createComponents('samus')

  estore

L.gameSystems = ->
  [
    CommonSystems.timer_system
    CommonSystems.death_timer_system
    CommonSystems.animation_timer_system
    CommonSystems.sound_system
    SamusSystems.samus_motion
    CommonSystems.controller_system
    EnemiesSystems.zoomer_controller_system # XXX
    EnemiesSystems.zoomer_crawl_system
    SamusSystems.samus_controller_action
    SamusSystems.short_beam_system
    SamusSystems.samus_action_velocity
    CommonSystems.samus_hit_system
    CommonSystems.samus_damage_system
    SamusSystems.samus_action_sounds
    CommonSystems.gravity_system
    CommonSystems.map_physics_system
    CommonSystems.map_ghost_system
    CommonSystems.bullet_enemy_system
    CommonSystems.bullet_system
    CommonSystems.enemy_hit_system
    EnemiesSystems.skree_action
    SamusSystems.samus_animation
  ]

L.spriteConfigs = ->
  TestLevel.spriteConfigs() # XXX yuck

L.graphicsToPreload = ->
  TestLevel.graphicsToPreload() # XXX yuck

L.soundsToPreload = ->
  TestLevel.soundsToPreload() # XXX yuck

module.exports = L

