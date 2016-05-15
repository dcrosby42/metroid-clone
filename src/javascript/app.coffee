Config = require './config'

jquery    = require 'jquery'

PixiHarness = require './pixi_ext/pixi_harness'
Immutable = require 'immutable'
window.Immutable = Immutable

React = require 'react'

MetroidDelegate = require './game/metroid_delegate'

Profiler = require './profiler'
Profiler.useAjaxReporter()
# Profiler.enable()
# Profiler.disable()
#


BigScreen = require './vendor/bigscreen_wrapper'

Inspector = require './inspector'
SystemLogInspector = require './system_log_inspector'

window.ObjectStore = require './search/object_store'
window.ObjectStoreSearch = require './search/object_store'

inspectorConfig = Immutable.fromJS
  componentLayout:
    samus:      { open: false }
    skree:      { open: false }
    zoomer:      { open: false }
    hit_box:      { open: false }
    controller: { open: false }
    animation:     { open: false }
    velocity:   { open: false }
    position:   { open: false }

jquery ->
  inspectorHolder = jquery('#inspector-holder')[0]
  componentInspector = null
  if Config.inspector.enabled
    componentInspector = Inspector.createComponentInspector
      mountNode: inspectorHolder
      inspectorConfig: inspectorConfig
  devUIDiv = jquery('#dev-ui')[0]
  systemLogInspector = null
  if Config.system_log.enabled
    systemLogInspector = SystemLogInspector.create
      mountNode: jquery('#system-log-holder')[0]

  del = new MetroidDelegate(componentInspector: componentInspector, adminUIDiv: devUIDiv, systemLogInspector: systemLogInspector)

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

