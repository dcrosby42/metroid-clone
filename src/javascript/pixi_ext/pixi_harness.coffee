PIXI = require 'pixi.js'
StopWatch = require './stop_watch'
CompositeEvent = require '../utils/composite_event'

class PixiHarness
  constructor: ({@domElement, @delegate, stage_background, width, height})->
    @stage = new PIXI.Stage(stage_background)
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
    ids = []
    manifest = []
    _.forOwn assets, (src,id) ->
      ids.push id
      manifest.push {id:id, src:src}

    soundsLoadedEvent = CompositeEvent.create ids, callback

    createjs.Sound.addEventListener "fileload", (event) ->
      soundsLoadedEvent.notify event.id

    createjs.Sound.alternateExtensions = ["mp3"]
    createjs.Sound.registerSounds manifest
   
  update: ->
    dt = @stopWatch.lapInMillis()
    if dt > 1000
      console.log "SKIPPING UPDATE, long dt: #{dt}"
    else
      @delegate.update dt

    @renderer.render(@stage)
    requestAnimationFrame => @update()

module.exports = PixiHarness
