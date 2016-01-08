jquery    = require 'jquery'

PixiHarness = require './pixi_ext/pixi_harness'
Immutable = require 'immutable'

React = require 'react'

MetroidCloneDelegate = require './game/metroid_clone_delegate'
ShapesUiDelegate = require './game/shapes_ui_delegate'
DelegateClass = MetroidCloneDelegate
# DelegateClass = ShapesUiDelegate

Profiler = require './profiler'
Profiler.useAjaxReporter()
# Profiler.enable()
# Profiler.disable()


BigScreen = require './vendor/bigscreen_wrapper'

Inspector = require './inspector'
DevUI = require './dev_ui'

inspectorConfig = Immutable.fromJS
  componentLayout:
    samus:      { open: false }
    skree:      { open: false }
    zoomer:      { open: true }
    hit_box:      { open: true }
    controller: { open: false }
    animation:     { open: false }
    velocity:   { open: true }
    position:   { open: true }

jquery ->
  inspectorHolder = jquery('#inspector-holder')[0]
  componentInspector = Inspector.createComponentInspector
    mountNode: inspectorHolder
    inspectorConfig: inspectorConfig
  devUIDiv = jquery('#dev-ui')
  devUI = DevUI.create(devUIDiv)

  del = new DelegateClass(componentInspector: componentInspector, devUI: devUI)

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

  window.stage = harness.stage
  
  window.Scene =
    nodes: ->
      sceneToNames(harness.stage)
    printNodes: ->
      printTree(sceneToNames(harness.stage))
 

# for console debugging and messing around:
window.$  = jquery
window._  = require 'lodash'

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

