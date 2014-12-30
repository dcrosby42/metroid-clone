PIXI = require 'pixi.js'
_    = require 'lodash'

debug = (a...) ->
  console.log "SpriteDeck DEBUG: ", a...

class SpriteDeck extends PIXI.DisplayObjectContainer

  constructor: (@sprites={}) ->
    @state = null
    @index = null
    super
    _.forOwn @sprites, (sprite,state) =>
      if _.isArray(sprite)
        for s in sprite
          @addChild s
      else
        @addChild sprite

  display: (state, index=0) ->
    return if state == @state and index == @index
    nextSprite = @getSprite state,index
    if nextSprite
      nextSprite.visible = true
      prevSprite = @getSprite @state,@index
      if prevSprite
        prevSprite.visible = false
      @state = state
      @index = index
    else

  getSprite: (state, index=0) ->
    arr = @sprites[state]
    if arr
      arr[index]

  @createSprites: (config) ->
    propsForAll = config.props || {}
    sprites = {}
    _.forOwn config.states, (data, state) ->
      mods = _.clone(propsForAll)
      _.merge(mods, data.props)
      if state == 'stand-right' or state == 'jump-right'
        debug propsForAll, data.props, mods
      if data.frame?
        sprites[state] = [ SpriteDeck._buildSprite(data.frame, mods) ]
      else if data.frames?
        sprites[state] = _.map data.frames, (frame) -> SpriteDeck._buildSprite(frame, mods)
      else
        console.log "SpriteDeck.create: data for '#{state}' missing either 'frame' or 'frames'"
    sprites

  @create: (config) ->
    sprites = SpriteDeck.createSprites(config)
    new SpriteDeck(sprites)

  @_buildSprite: (frame, mods) ->
    sprite = PIXI.Sprite.fromFrame(frame)
    sprite.visible = false
    if mods?
      SpriteDeck._applyMods(sprite, mods)
    sprite

  @_applyMods: (obj, mods) ->
    _.forOwn mods, (data,key) ->
      if _.isPlainObject(data)
        SpriteDeck._applyMods(obj[key], data)
      else
        obj[key] = data





module.exports = SpriteDeck

