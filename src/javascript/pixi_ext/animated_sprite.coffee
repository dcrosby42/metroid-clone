PIXI = require 'pixi.js'
_    = require 'lodash'
SpriteDeck = require './sprite_deck'
Timeline = require './timeline'

class AnimatedSprite extends SpriteDeck

  constructor: (sprites,@timelines,@config) ->
    super sprites
    @spriteSheet = @config.spriteSheet

  displayAnimation: (state, time=0) ->
    timeline = @timelines[state]
    if timeline
      i = timeline.itemAtTime(time)
      @display(state,i)


  @createTimelines: (config) ->
    timelines = []
    _.forOwn config.states, (data,state) ->
      frames = if data.frames?
        data.frames
      else
        [ data.frame ]

      frameDelayMillis = 1000 / data.fps
      frameIndices = _.range(0,frames.length)
      timeline = Timeline.createTimedEvents(frameDelayMillis, frameIndices, true)
      timelines[state] = timeline
    timelines

  @create: (config) ->
    spriteDeck = SpriteDeck.createSprites(config)
    timelines = AnimatedSprite.createTimelines(config)
    new AnimatedSprite(spriteDeck, timelines, config)

module.exports = AnimatedSprite

