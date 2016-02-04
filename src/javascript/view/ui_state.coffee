PIXI = require "pixi.js"

MetroidLayerDefs = {
  children:
    [
      {
        id: 'base'
        name: "Base Layer"
        children: [
          {
            id: 'creatures'
            name: 'Creatures Layer'
          }
          {
            id: 'rooms'
            name: 'Rooms Layer'
          }
          {
            id: 'doors'
            name: 'Doors Layer'
          }
        ]
      }
      {
        id: 'overlay'
        name: "Overlay Layer"
      }
    ]
  aliases:
    default: 'creatures'
}

class UIState
  @Defaults =
    zoomScale: 2.0
    aspectScale:
      x: 1.25
      y: 1.0
  
  constructor: ({stage, zoomScale, soundController, aspectScale}) ->
    # @_layers = @_createLayers(stage,zoomScale,aspectScale)
    @_layers = @_createLayers_old(stage,zoomScale,aspectScale)
    @_objectCaches = {}
    @_currentMapName = null
    @drawHitBoxes = false
    @soundController = soundController

  getLayer: (layerName) ->
    @_layers[layerName] || @_layers.default

  addObjectToLayer: (object,layer) ->
    @getLayer(layer).addChild object
    object

  objectCacheFor: (cacheName) ->
    @_objectCaches[cacheName] ?= {}

  playSound: (soundId) ->
    @soundController.playSound(soundId)

  _createLayers: (stage,zoomScale,aspectScale) ->
    zoomScale ?= @constructor.Defaults.zoomScale
    aspectScale ?= @constructor.Defaults.aspectScale

    scaler = new PIXI.DisplayObjectContainer()
    scaler.scale.set(aspectScale.x * zoomScale, aspectScale.y * zoomScale)
    scaler._name = "Scaler Layer - (#{scaler.scale.x},#{scaler.scale.y})"

    stage.addChild scaler

    layers = {}
    layers.scaler = scaler
    layers.maps = {}

    newLayer = (info) ->
      l = new PIXI.DisplayObjectContainer()
      l._name = info.name
      layers[info.id] = l
      l

    addChildren = (layer,cinfos) ->
      return unless cinfos?
      for cinfo in cinfos
        cl = newLayer(cinfo)
        addChildren(cl,cinfo.children)
        layer.addChild cl

    defs = MetroidLayerDefs
        
    addChildren(scaler, defs.children)

    if defs.aliases?
      for k,v of defs.aliases
        layers[k] = layers[v]

    return layers

  muteAudio: ->
    @soundController.muteAll()

  unmuteAudio: ->
    @soundController.unmuteAll()

  @create: (a...) -> new @(a...)

module.exports = UIState

