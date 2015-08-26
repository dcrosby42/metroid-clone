_ = require 'lodash'
sprites = require './sprites'
# factory = require './factory'

assets = _.uniq _.map _.values(sprites), (info) ->
  return info.image if info.image?
  return info.spriteSheet if info.spriteSheet?
  console.log "!! entity/general/index: no 'image' or 'spriteSheet' value in sprite info:",info
  return null

assets = _.without(assets,null)

module.exports =
  sprites: sprites
  assets: assets
  # factory: factory
  # components: components

