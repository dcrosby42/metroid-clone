PIXI = require 'pixi.js'
StopWatch = require './stop_watch'
CompositeEvent = require '../utils/composite_event'
ProfilerThing = require '../utils/profiler_thing'
BufferedPusher = require '../utils/buffered_pusher'
SoundController = require './sound_controller'

jquery = require 'jquery'
profilingCaptureUrl = "http://127.0.0.1:5012/capture-data"

class PixiHarness
  constructor: ({@domElement, @delegate, stageBgColor, width, height,@zoom})->
    @stage = new PIXI.Stage(stageBgColor)
    @renderer = PIXI.autoDetectRenderer(width,height)
    @view = @renderer.view
    @domElement.appendChild @view
    @stopWatch = new StopWatch()
    @prof = new ProfilerThing()

    flushToServer = (buffer,_) -> jquery.post profilingCaptureUrl, JSON.stringify(data: buffer)
    flushToConsole = (buffer,_) -> console.log buffer
    every60 = BufferedPusher.Conditions.length(60)
    # @dataSender = new BufferedPusher(flushToConsole, every60)
    @dataSender = new BufferedPusher(flushToServer, every60)

  start: ->
    @_loadAssets =>
      console.log "Assets loaded."
      @delegate.setupStage @stage, @renderer.view.offsetWidth, @renderer.view.offsetHeight, @zoom, @prof
      @stopWatch.start()
      requestAnimationFrame => @update()

  _loadAssets: (callback) ->
    allDone = CompositeEvent.create ["graphics", "sounds"], callback

    if @delegate.graphicsToPreload?
      # console.log "GRAPHICS PRELOAD:",@delegate.graphicsToPreload()
      @_loadGraphicalAssets @delegate.graphicsToPreload(), allDone.notifier("graphics")
    else
      allDone.notify "graphics"

    if @delegate.soundsToPreload?
      # console.log "SOUNDS PRELOAD:",@delegate.soundsToPreload()
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
      updateStart = @stopWatch.currentTimeMillis()
      @delegate.update dt
      updateTime = @stopWatch.currentTimeMillis() - updateStart

    @renderer.render(@stage)

    item = @prof.tear(dt: dt, updateTime: updateTime)
    @dataSender.push item

    requestAnimationFrame => @update()

module.exports = PixiHarness
