ViewSystem = require "./view_system"
ArrayToCacheBinding = require '../pixi_ext/array_to_cache_binding'


class ViewObjectSyncSystem extends ViewSystem
  # EntityStore component query.
  #   Eg, [T.Label, T.Position]
  @Subscribe: null

  # Assumed result slot # to pull the 'synced' component from 
  #   Default 0
  @SyncComponentInSlot: 0

  # Name of the UI display object cache to sync vs. Components
  #   Eg, "label"
  @CacheName: null

  constructor: ->
    super()
    @_syncInSlot = @constructor.SyncComponentInSlot
    @_cacheName = @constructor.CacheName
    # TODO error checking and defaults?


  # XXX we inherit from BaseSystem which really watns this at constructor time, but for pointless reasons.  Do nothing. Delete when this is solved.
  process: ->
   
  processAll: ->
    cache = @uiState.compSetFor(@_cacheName)

    incomingCids = []
    @searcher.run @estore, (r) =>
      comp = r.comps[@_syncInSlot]
      cid = comp.cid
      incomingCids.push cid # TODO icky push.  self-growing cids array?

      if cacheItem = cache.getByCid(cid)
        # Update existing cached dislpay object
        @updateObject(r,cacheItem.object)

      else
        # Create and cache new display object
        object = @newObject(r)
        cache.add(new CacheItem(cid,object))
        # (update it)
        @updateObject(r,object)
    
    cache.each (cacheItem) ->
      if incomingCids.indexOf(cacheItem.cid) == -1
        # Delete no-longer-relevant display object
        @removeObject(cacheItem.object)
        cache.deleteByCid(cacheItem.cid)


  # Invoked once a Component appears that is not yet represented in the UI.
  # Must be overridden by subclasses.
  # Must return a PIXI.DisplayObject, like a Text or Sprite instance or subclass thereof.
  newObject: (r) ->
    console.log "!! ViewObjectSyncSystem subclasses MUST implement 'newObject(comps)'"

  # Invoked during each update.  Subclasses should override to apply changes derrived from
  # the Components in 'comps' to the 'displayObject'
  # Optionally (usually) overridden by subclasses. 
  # Must return a PIXI.DisplayObject, like a Text or Sprite instance or subclass thereof.
  updateObject: (r,displayObject) ->

  # Invoked once a Component that was previously represented in the UI is no longer present in the game state.
  # Default implementation is to remove the given displayObject from it's parent.
  # Optionally (infrquently) overridden by subclasses.
  removeObject: (displayObject) ->
    if displayObject?
      if displayObject.parent?
        displayObject.parent.removeChild displayObject


class CacheItem
  constructor: (@cid,@object) ->

module.exports = ViewObjectSyncSystem
