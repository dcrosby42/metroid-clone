PIXI = require 'pixi.js'
_    = require 'lodash'

debug = ->
# debug = (a...) ->
#   console.log "SpriteDeck DEBUG: ", a...

class FauxSprite
  constructor: ->
    @visible = false
    @isFauxSprite = true

class SpriteDeck extends PIXI.DisplayObjectContainer

  constructor: (@sprites={}) ->
    @state = null
    @index = null
    super
    _.forOwn @sprites, (sprite,state) =>
      if _.isArray(sprite)
        for s in sprite
          @addChild s unless s.isFauxSprite
      else
        @addChild sprite unless s.isFauxSprite

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
      frames = if data.frame?
        [ data.frame ]
      else if data.frames?
        data.frames
      else
        console.log "SpriteDeck.create: data for '#{state}' missing either 'frame' or 'frames'"
      if frames?
        sprites[state] = _.map frames, (frame) -> SpriteDeck._buildSprite(frame, mods)

    sprites

  @create: (config) ->
    sprites = SpriteDeck.createSprites(config)
    new SpriteDeck(sprites)

  @_buildSprite: (frame, mods) ->
    sprite = if frame == "_BLANK_"
      new FauxSprite()
    else
      PIXI.Sprite.fromFrame(frame)

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

