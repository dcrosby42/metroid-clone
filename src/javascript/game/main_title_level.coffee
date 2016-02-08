_ = require 'lodash'
Immutable = require 'immutable'

RoomsLevel = require './rooms_level'

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
  ]

  estore

L.gameSystems = ->
  [
    CommonSystems.timer_system
    CommonSystems.death_timer_system
    CommonSystems.animation_timer_system
    CommonSystems.sound_system
    CommonSystems.controller_system
    CommonSystems.main_title_system
  ]

L.spriteConfigs = ->
  RoomsLevel.spriteConfigs() # XXX why are we referring to RoomsLevel directly??

L.graphicsToPreload = ->
  assets = []
  assets.push("images/main_title.png")
  assets

L.soundsToPreload = ->
  songs = ["main_title"]
  effects = []

  assets = {}
  for song in songs
    assets[song] = "sounds/music/#{song}.mp3"
  for effect in effects
    assets[effect] = "sounds/fx/#{effect}.wav"

  assets

module.exports = L

