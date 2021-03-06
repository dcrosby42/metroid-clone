_ = require 'lodash'
sprites = require './sprites'
factory = require './factory'
components = require './components'

assets = _.uniq _.map _.values(sprites), (info) -> info.spriteSheet


module.exports =
  sprites: sprites
  assets: assets
  factory: factory
  components: components

