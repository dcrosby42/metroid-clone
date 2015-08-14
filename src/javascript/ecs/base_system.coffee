FilterExpander = require './filter_expander'

class BaseSystem
  # Search pattern for components
  @Subscribe: null

  # If not easily inferred from the Subscribe property, provides the component name
  # from which to extract eid when performing convenience functions that assume an Entity.
  @ImplyEntity: null

  # Singleton instance of the system, instantiated on first use
  @Instance: ->
    @_singleton_instance ||= new @()

  constructor: ->
    @componentFilters = FilterExpander.expandFilterGroups(@constructor.Subscribe)
    @_primaryComponentName = @constructor.ImplyEntity || @constructor.Subscribe[0]
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

  dt: ->
    @input.get('dt')

  eid: ->
    @getProp(@_primaryComponentName,'eid')

  getComp: (compName) ->
    comp = @cache[compName]
    if !comp?
      comp = @comps.get(compName)
      unless comp?
        console.log "!! BaseSystem#get: system not subscribed for '#{compName}'"
      @cache[compName] = comp
      @nameCache[comp.get('cid')] = compName
    comp

  getProp: (compName, propName) ->
    @getComp(compName).get(propName)

  setProp: (compName, propName, value) ->
    comp = @getComp(compName)
    comp2 = comp.set(propName, value)
    @_updated(compName,comp2) unless comp == comp2

  updateProp: (compName, propName, fn) ->
    comp = @getComp(compName)
    comp2 = comp.update(propName, fn)
    @_updated(compName,comp2) unless comp == comp2

  updateComp: (comp) ->
    compName = @nameCache[comp.get('cid')]
    @_updated(compName,comp) unless @cache[compName] == comp

  _updated: (compName, comp) ->
    @cache[compName] = comp
    @updatedComps[compName] = comp
    @updatedCompNames.push compName

  deleteComp: (comp) ->
    @compsToDelete.push comp

  addComp: (props) ->
    @compsToAdd.push [@eid(),props]

  addEntityComp: (eid, props) ->
    @compsToAdd.push [eid,props]

  newEntity: (comps) ->
    @entitiesToAdd.push comps

  destroyEntity: (eid=null) ->
    eid ?= @eid()
    @entitiesToDelete.push eid

  # TODO: rethink?  Systems reaching out to the estore breaks the pattern
  # BUT! Currently, there are systems that need to go find components.
  getEntityComponents: (eid, type, matchKey=null, matchVal=null) ->
    @updater.getEntityComponents(eid, type, matchKey, matchVal)

  # TODO: rethink?  Systems reaching out to the estore breaks the pattern
  getEntityComponent: (eid, type, matchKey=null, matchVal=null) ->
    @updater.getEntityComponent(eid, type, matchKey, matchVal)

  # TODO: rethink?  Systems reaching out to the estore breaks the pattern
  # updateEntityComponent: (eid, type, atts) ->
  #   @updater.updateEntityComponent(eid,type,atts)


  #
  # EVENTS
  #

  getEvents: -> @eventBucket.getEventsForEntity(@eid())
  getEntityEvents: (eid) -> @eventBucket.getEventsForEntity(eid)

  publishEvent: (event,data=null) -> @eventBucket.addEventForEntity(@eid(),event,data)
  publishEntityEvent: (eid,event,data=null) -> @eventBucket.addEventForEntity(eid,event,data)

  publishGlobalEvent: (event,data=null) -> @eventBucket.addGlobalEvent(event,data)
  

module.exports = BaseSystem
