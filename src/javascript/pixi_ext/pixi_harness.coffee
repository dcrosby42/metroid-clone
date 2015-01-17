PIXI = require 'pixi.js'
StopWatch = require './stop_watch'
CompositeEvent = require '../utils/composite_event'
SoundController = require './sound_controller'

class PixiHarness
  constructor: ({@domElement, @delegate, stageBgColor, width, height})->
    @stage = new PIXI.Stage(stageBgColor)
    @renderer = PIXI.autoDetectRenderer(width,height)
    @view = @renderer.view
    @domElement.appendChild @view
    @stopWatch = new StopWatch()


  start: ->
    @_loadAssets =>
      console.log "Assets loaded."
      @delegate.setupStage @stage, @renderer.view.offsetWidth, @renderer.view.offsetHeight
      @stopWatch.start()
      requestAnimationFrame => @update()

  _loadAssets: (callback) ->
    allDone = CompositeEvent.create ["graphics", "sounds"], callback

    @_loadGraphicalAssets @delegate.graphicsToPreload(), allDone.notifier("graphics")
    if @delegate.soundsToPreload?
      @_loadSoundAssets @delegate.soundsToPreload(), allDone.notifier("sounds")
    else
      allDone.notify "sounds"

  _loadGraphicalAssets: (assets, callback) ->
    loader = new PIXI.AssetLoader(assets)
    loader.onComplete = callback
    loader.load()

  _loadSoundAssets: (assets, callback) ->
    SoundController.loadSoundMap assets, callback
   
  update: ->
    dt = @stopWatch.lapInMillis()
    if dt > 1000
      console.log "SKIPPING UPDATE, long dt: #{dt}"
    else
      @delegate.update dt

    @renderer.render(@stage)
    requestAnimationFrame => @update()

module.exports = PixiHarness
