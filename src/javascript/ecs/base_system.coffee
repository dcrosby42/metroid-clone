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
    @cache[compName] = comp
    @updatedComps[compName] = comp
    @updatedCompNames.push compName

  updateProp: (compName, propName, fn) ->
    comp = @get(compName)
    comp2 = comp.update(propName, fn)
    if comp != comp2
      @cache[compName] = comp2
      @updatedComps[compName] = comp2
      @updatedCompNames.push compName

  setProp: (compName, propName, value) ->
    comp = @get(compName)
    comp2 = comp.set(propName, value)
    if comp != comp2
      @cache[compName] = comp2
      @updatedComps[compName] = comp2
      @updatedCompNames.push compName

  delete: (comp) ->
    @updater.delete(comp)

  add: (eid, props) ->
    @updater.add(eid, props)

  newEntity: (comps) ->
    @updater.newEntity comps

  destroyEntity: (eid) ->
    @updater.destroyEntity eid

  getEntityComponents: (eid, type) ->
    @updater.getEntityComponents(eid, type)

  getEntityComponent: (eid, type) ->
    @updater.getEntityComponent(eid, type)

  updateEntityComponent: (eid, type, atts) ->
    @updater.updateEntityComponent(eid,type,atts)

  sync: ->
    for name in @updatedCompNames
      @updater.update @updatedComps[name]

  getEvents: (eid) ->
    @eventBucket.getEventsForEntity(eid)

  publishEvent: (eid,event) ->
    @eventBucket.addEventForEntity(eid,event)

  broadcastEvent: (event) ->
    @eventBucket.addGlobalEvent(event)
  

module.exports = BaseSystem
