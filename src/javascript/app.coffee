jquery    = require 'jquery'

PixiHarness = require './pixi_ext/pixi_harness'
# OneRoom = require './game/one_room'
# MapSpike = require './game/map_spike'
# BoxDrawSpike = require './game/box_draw_spike'
# CollisionSpike = require './game/collision_spike'
# SamusPreview = require './game/samus_preview'
# SkreePreview = require './samus/skree_preview'
Ecs2Spike = require './game/ecs2_spike'
DelegateClass = Ecs2Spike

BigScreen = require './vendor/bigscreen_wrapper'

Inspector = require './inspector'


jquery ->
  gameHolder = jquery('#game-holder')[0]
  inspectorHolder = jquery('#inspector-holder')[0]

  componentInspector = Inspector.createComponentInspector(inspectorHolder)
  del = new DelegateClass(componentInspector: componentInspector)

  harness = new PixiHarness
    domElement: gameHolder
    delegate: del
    width: 640
    height: 480
    stage_background: 0x000000

  harness.start()


  gameView = harness.view
  $('#fullscreen').on "click", ->
    BigScreen.doTheBigThing gameView


# for console debugging and messing around:
window.$  = jquery
window._  = require 'lodash'
