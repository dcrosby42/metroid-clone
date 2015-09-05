_ = require 'lodash'
Immutable = require 'immutable'

# MapDatabase = require './map/map_database'

# Enemies = require './entity/enemies'
# EnemiesSystems =  require './entity/enemies/systems'
#
# Samus = require './entity/samus'
# SamusSystems =  require './entity/samus/systems'

General = require './entity/general'
CommonSystems = require './systems'

Common = require './entity/components'

ShapesLevel = {}

ShapesLevel.populateInitialEntities = (estore) ->
  estore.createEntity [
    Common.Name.merge(name: 'HelloWorld')
    Common.Label.merge
      content: "Hello World"
      layer: 'shapes'
      fill_color: '#ddffdd'
      font: "normal 14pt Arial"
    Common.Position.merge
      x: 0
      y: 0
    Common.HitBoxVisual.merge
      color: 0xffffff
      layer: 'shapes'
    Common.HitBox.merge
      x: 0
      y: 0
      width: 72
      height: 15
      anchorX: 0
      anchorY: 0
  ]


  estore

ShapesLevel.gameSystems = ->
  [
  ]

ShapesLevel.spriteConfigs = ->
  spriteConfigs = {}
  # _.merge spriteConfigs, Samus.sprites
  # _.merge spriteConfigs, Enemies.sprites
  # _.merge spriteConfigs, General.sprites
  spriteConfigs

# XXX
# _mapDb = MapDatabase.createDefault()
ShapesLevel.mapDatabase = ->
#   _mapDb
  null

ShapesLevel.graphicsToPreload = ->
  assets = [
  ]
  # assets = assets.concat(Samus.assets)
  # assets = assets.concat(Enemies.assets)
  # assets = assets.concat(General.assets)

  assets

ShapesLevel.soundsToPreload = ->
  songs = []
  effects = [
  ]
  assets = {}
  for song in songs
    assets[song] = "sounds/music/#{song}.mp3"
  for effect in effects
    assets[effect] = "sounds/fx/#{effect}.wav"
  assets

module.exports = ShapesLevel

