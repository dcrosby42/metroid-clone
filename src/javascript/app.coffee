jquery    = require 'jquery'

PixiHarness = require './pixi_ext/pixi_harness'
BigScreen = require './vendor/bigscreen_wrapper'
MetroidDelegate = require './game/metroid_delegate'

Profiler = require './profiler'
Profiler.useAjaxReporter()
# Profiler.enable()
# Profiler.disable()


# for console debugging and messing around:
window.$  = jquery
window._  = require 'lodash'
window.Immutable = require 'immutable'
window.ObjectStore = require './search/object_store'
window.ObjectStoreSearch = require './search/object_store'

#
# ON STARTUP
#
jquery ->
  devUIDiv = jquery('#dev-ui')[0]

  del = new MetroidDelegate(adminUIDiv: devUIDiv)

  gameHolder = jquery('#game-holder')[0]
  harness = new PixiHarness
    domElement: gameHolder
    delegate: del
    # width: 640
    # height: 480
    # zoom: 1.0
    width: 640
    height: 480
    zoom: 2.0
    # width: 320
    # height: 240
    # zoom: 1.0
    stage_background: 0x000000

  harness.start()

  $('#fullscreen').on "click", ->
    BigScreen.doTheBigThing harness.view

  PixiHarness.setupSceneDebug(window,stage)
 

