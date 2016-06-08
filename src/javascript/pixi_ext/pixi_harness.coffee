PIXI = require 'pixi.js'
jquery    = require 'jquery'
StopWatch = require './stop_watch'
CompositeEvent = require '../utils/composite_event'
SoundController = require './sound_controller'
Profiler = require '../profiler'
# microtime = require 'microtime'

class DataFileLoader
  constructor: ->
    @data = {}

  loadDataAssets: (dataAssets,callback) ->
    @data = {}
    names = _.map(dataAssets, (a) -> a.name)
    allDataLoaded = CompositeEvent.create names, callback
    for a in dataAssets
      @_loadFile a.name, a.file, allDataLoaded.notifier(a.name)

  loadDataFiles: (filemap,callback) ->
    @data = {}
    names = _.keys(filemap)
    allDataLoaded = CompositeEvent.create _.keys(filemap), callback
    for name,file of filemap
      @_loadFile name,file,allDataLoaded.notifier(name)

  _loadFile: (name,file,callback) ->
    jquery.getJSON(file).done((data) =>
      @data[name] = data
      callback()
    ).fail( (err) =>
      console.log "  ERR! dataFileLoader name='#{name}' file='#{file}' err=",err
      callback()
    )

class PixiHarness
  constructor: ({@domElement, @delegate, stageBgColor, width, height,@zoom})->
    @stage = new PIXI.Stage(stageBgColor)
    @stage._name = "Stage"
    @renderer = PIXI.autoDetectRenderer(width,height)
    @view = @renderer.view
    @domElement.appendChild @view
    @stopWatch = new StopWatch()
    @soundController = SoundController
    @dataFileLoader = new DataFileLoader()

  start: ->
    @_loadAssets =>
      console.log "PixiHarness: assets loaded; initializing delegate"
      @delegate.initialize @stage, @renderer.view.offsetWidth, @renderer.view.offsetHeight, @zoom, @soundController, @dataFileLoader.data
      @stopWatch.start()
      requestAnimationFrame (t) => @update(t)

  _loadAssets: (callback) ->
    allDone = CompositeEvent.create ["graphics", "sounds", "data"], callback

    if @delegate.assetsToPreload?
      soundAssets = []
      graphicAssets = []
      dataAssets = []
      for asset in @delegate.assetsToPreload()
        switch asset.type
          when 'sound'   then soundAssets.push(asset)
          when 'graphic' then graphicAssets.push(asset)
          when 'data'    then dataAssets.push(asset)
      @_loadData            dataAssets,    allDone.notifier("data")
      @_loadGraphicalAssets graphicAssets, allDone.notifier("graphics")
      @_loadSoundAssets     soundAssets,   allDone.notifier("sounds")
    else
      allDone.notify "data"
      allDone.notify "graphics"
      allDone.notify "sounds"


  _loadData: (assets, callback) ->
    if assets? and assets.length > 0
      @dataFileLoader.loadDataAssets(assets, callback)
    else
      callback()

  _loadGraphicalAssets: (assets, callback) ->
    if assets? and assets.length > 0
      files = _.map(assets, (a) -> a.file)
      loader = new PIXI.AssetLoader(files)
      graphics = assets
      loader.onComplete = ->
        callback()
      loader.load()
    else
      callback()

  _loadSoundAssets: (assets, callback) ->
    if assets? and assets.length > 0
      soundMap = {}
      for a in assets
        soundMap[a.name] = a.file
      @soundController.loadSoundMap soundMap, callback
    else
      callback()

  update: (t) ->
    dt = null
    if @lastT?
      dt = t - @lastT
    @lastT = t
    if dt?
      if dt > 1000
        console.log "SKIPPING UPDATE, long dt: #{dt}"
      else
        start = new Date().getTime()
        @delegate.update dt
        ellapsedMillis = new Date().getTime() - start

    @renderer.render(@stage)

    Profiler.tear(dt: dt, updateTime: ellapsedMillis)

    requestAnimationFrame (t) => @update(t)

#
# Debug stuff
#
PixiHarness.setupSceneDebug = (win,stage) ->
  win.stage = stage
  win.Scene =
    nodes: ->
      sceneToNames(stage)
    printNodes: ->
      printTree(sceneToNames(stage))

sceneToNames = (obj) ->
  n = {}
  n.name = obj._name or "??"
  if obj.children
    n.children = _.map(obj.children, sceneToNames)
  n

printTree = (node, indent=0) ->
  s = ""
  s += "  " for [0...indent]
  s += node.name
  console.log s
  if node.children
    printTree(c, indent+1) for c in node.children
  null


module.exports = PixiHarness
