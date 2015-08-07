FilterExpander = require './filter_expander'

class BaseSystem
  @SystemType: 'BaseSystem'
  @Subscribe: null

  @Instance: ->
    @_singleton_instance ||= new @()

  constructor: ->
    @componentFilters = FilterExpander.expandFilterGroups(@constructor.Subscribe)
    @reset()

  setup: (@comps,@input,@updater,@eventBucket) ->

  handleUpdate: (comps, input, u, eventBucket) ->
    @setup(comps,input,u,eventBucket)
    @process()
    @sync()
    @reset()
    
  reset: ->
    @comps = null
    @input = null
    @updater = null
    @eventBucket = null
    @cache = {}
    @nameCache = {}
    @updatedComps = {}
    @updatedCompNames = []
    @compsToAdd = []
    @compsToDelete = []
    @entitiesToAdd = []
    @entitiesToDelete = []

  process: ->

  dt: ->
    @input.get('dt')

  get: (compName) ->
    comp = @cache[compName]
    if !comp?
      comp = @comps.get(compName)
      @cache[compName] = comp
      @nameCache[comp.get('cid')] = compName
    comp

  getProp: (compName, propName) ->
    @get(compName).get(propName)

  update: (comp) ->
    compName = @nameCache[comp.get('cid')]
    @_updated(compName,comp) unless @cache[compName] == comp

  updateProp: (compName, propName, fn) ->
    comp = @get(compName)
    comp2 = comp.update(propName, fn)
    @_updated(compName,comp2) unless comp == comp2

  setProp: (compName, propName, value) ->
    comp = @get(compName)
    comp2 = comp.set(propName, value)
    @_updated(compName,comp2) unless comp == comp2

  delete: (comp) ->
    @compsToDelete.push comp

  addComponent: (eid, props) ->
    @compsToAdd.push [eid,props]

  newEntity: (comps) ->
    @entitiesToAdd.push comps

  destroyEntity: (eid) ->
    @entitiesToDelete.push eid

  # TODO: rethink?  Systems reaching out to the estore breaks the pattern
  getEntityComponents: (eid, type) ->
    @updater.getEntityComponents(eid, type)

  # TODO: rethink?  Systems reaching out to the estore breaks the pattern
  getEntityComponent: (eid, type) ->
    @updater.getEntityComponent(eid, type)

  # TODO: rethink?  Systems reaching out to the estore breaks the pattern
  updateEntityComponent: (eid, type, atts) ->
    @updater.updateEntityComponent(eid,type,atts)

  _updated: (compName, comp) ->
    @cache[compName] = comp
    @updatedComps[compName] = comp
    @updatedCompNames.push compName

  sync: ->
    for name in @updatedCompNames
      @updater.update @updatedComps[name]
    for comp in @compsToDelete
      @updater.delete(comp)
    for [eid,props] in @compsToAdd
      @updater.add(eid, props)
    for comps in @entitiesToAdd
      @updater.newEntity(comps)
    for eid in @entitiesToDelete
      @updater.destroyEntity(eid)

  getEvents: (eid) ->
    @eventBucket.getEventsForEntity(eid)

  publishEvent: (eid,event) ->
    @eventBucket.addEventForEntity(eid,event)

  broadcastEvent: (event) ->
    @eventBucket.addGlobalEvent(event)
  

module.exports = BaseSystem
