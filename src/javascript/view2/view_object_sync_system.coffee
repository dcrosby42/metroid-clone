ViewSystem = require "./view_system"
ArrayToCacheBinding = require '../pixi_ext/array_to_cache_binding'

class ViewObjectSyncSystem extends ViewSystem
  # EntityStore component query.
  #   Eg, ['label', 'position']
  @Subscribe: null

  # Name of the UI display object cache to sync vs. Components
  #   Eg, "label"
  @CacheName: null

  # The key path to dig into a Component search result to identify a Component.
  #   Eg, ['label', 'cid']  ...use the label Component's cid as the uniqe identifier
  @Ident: null

  constructor: ->
    super()

    if @constructor.SyncComponent?
      @_cacheName = @constructor.SyncComponent
      @_identPath = [ @constructor.SyncComponent, 'cid' ]

    if @constructor.CacheName?
      @_cacheName = @constructor.CacheName

    if @constructor.Ident?
      @_identPath = @constructor.Ident

  # Not to be overridden by subclasses.
  process: ->
    # TODO: Reimplement a more locally-tailored version of ArrayToCacheBinding internal to this class.
    ArrayToCacheBinding.update
      source: @searchComponents().toArray()
      cache: @ui.objectCacheFor(@_cacheName)
      keyFn: (comps) => comps.getIn @_identPath
      addFn: (comps) => @newObject comps
      removeFn: (label) => @removeObject label
      syncFn: (comps,label) => @updateObject(comps,label)

  # Invoked once a Component appears that is not yet represented in the UI.
  # Must be overridden by subclasses.
  # Must return a PIXI.DisplayObject, like a Text or Sprite instance or subclass thereof.
  newObject: (comps) ->
    console.log "!! ViewObjectSyncSystem subclasses MUST implement 'newObject(comps)'"

  # Invoked during each update.  Subclasses should override to apply changes derrived from
  # the Components in 'comps' to the 'displayObject'
  # Optionally (usually) overridden by subclasses. 
  # Must return a PIXI.DisplayObject, like a Text or Sprite instance or subclass thereof.
  updateObject: (comps,displayObject) ->

  # Invoked once a Component that was previously represented in the UI is no longer present in the game state.
  # Default implementation is to remove the given displayObject from it's parent.
  # Optionally (infrquently) overridden by subclasses.
  removeObject: (displayObject) ->
    if displayObject?
      if displayObject.parent?
        displayObject.parent.removeChild displayObject

module.exports = ViewObjectSyncSystem

