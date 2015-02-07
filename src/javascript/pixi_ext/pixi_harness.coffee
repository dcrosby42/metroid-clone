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

    if @delegate.graphicsToPreload?
      @_loadGraphicalAssets @delegate.graphicsToPreload(), allDone.notifier("graphics")
    else
      allDone.notify "graphics"

    if @delegate.soundsToPreload?
      @_loadSoundAssets @delegate.soundsToPreload(), allDone.notifier("sounds")
    else
      allDone.notify "sounds"

  _loadGraphicalAssets: (assets, callback) ->
    if assets? and assets.length > 0
      loader = new PIXI.AssetLoader(assets)
      loader.onComplete = callback
      loader.load()
    else
      callback()

  _loadSoundAssets: (assets, callback) ->
    if _.keys(assets).length > 0
      SoundController.loadSoundMap assets, callback
    else
      callback()
   
  update: ->
    dt = @stopWatch.lapInMillis()
    if dt > 1000
      console.log "SKIPPING UPDATE, long dt: #{dt}"
    else
      @delegate.update dt

    @renderer.render(@stage)
    requestAnimationFrame => @update()

module.exports = PixiHarness
