jquery    = require 'jquery'

PixiHarness = require './pixi_ext/pixi_harness'
OneRoom = require './game/one_room'
# SamusPreview = require './game/samus_preview'
# SkreePreview = require './samus/skree_preview'
BigScreen = require './vendor/bigscreen_wrapper'

jquery ->
  el = jquery('#game-holder')[0]

  del = new OneRoom()
  # del = new SamusPreview()
  # del = new SkreePreview()
  harness = new PixiHarness
    domElement: el
    delegate: del
    width: 640
    height: 480
    stage_background: 0x000033

  harness.start()

  gameView = harness.view
  $('#fullscreen').on "click", ->
    BigScreen.doTheBigThing gameView


# for console debugging and messing around:
window.$  = jquery
window._  = require 'lodash'
