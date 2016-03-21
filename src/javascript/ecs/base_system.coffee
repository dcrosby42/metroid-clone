Immutable = require 'immutable'
FilterExpander = require './filter_expander'

addToResult = (result,key,obj) ->
  if result?
    result[key] ?= []
    result[key].push obj

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

  update: (estore, input, eventBucket, systemLog) ->
    @estore = estore
    @input = input
    @eventBucket = eventBucket
    if systemLog?
      systemLog.search = @componentFilters
      systemLog.results = []

    estore.search(@componentFilters).forEach (comps) =>
      result = null
      if systemLog?
        result = {
          components: comps
        }
        systemLog.results.push(result)

      @comps = comps
      @resetCache()
      @process()
      # @captureChanges(comps,systemLog) if systemLog?
      @sync(result)
      @resetCache() # for cleanliness; not strictly necessary

      @comps = null

    # for cleanliness; not strictly necessary:
    @estore = null
    @input = null
    @eventBucket = null

  resetCache: ->
    @cache = {}
    @nameCache = {}
    @updatedComps = {}
    @updatedCompNames = []
    @compsToAdd = []
    @compsToDelete = []
    @entitiesToAdd = []
    @entitiesToDelete = []

  process: ->

  sync: (result) ->
    for name in @updatedCompNames
      comp = @updatedComps[name]
      @estore.updateComponent @updatedComps[name]
      addToResult result, 'updatedComponents', comp
      # result.updatedComponents.push comp if result?

    for comp in @compsToDelete
      @estore.deleteComponent comp
      addToResult result, 'deletedComponents', comp
      # result.deletedComponents.push comp if result?
      
    for [eid,props] in @compsToAdd
      comp = @estore.createComponent eid, props
      addToResult result, 'newComponents', comp
      # result.newComponents.push comp if result?

    for comps in @entitiesToAdd
      eid = @estore.createEntity comps
      addToResult result, 'newEntities', {eid: eid, comps: comps} 

    for eid in @entitiesToDelete
      @estore.destroyEntity eid
      addToResult result, 'deletedEntities', eid

  dt: ->
    @input.get('dt')

  eid: ->
    @getProp(@_primaryComponentName,'eid')

  getComp: (compName) ->
    comp = @cache[compName]
    if !comp?
      comp = @comps.get(compName)
      unless comp?
        throw new Error("BaseSystem#get: system not subscribed for '#{compName}'")
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
    return comp2.get(propName)

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

  getEntityComponents: (eid, type, matchKey=null, matchVal=null) ->
    @estore.getEntityComponents(eid, type, matchKey, matchVal)

  getEntityComponent: (eid, type, matchKey=null, matchVal=null) ->
    @estore.getEntityComponent(eid, type, matchKey, matchVal)

  # TODO: rethink?  Systems reaching out to the estore breaks the pattern
  # updateEntityComponent: (eid, type, atts) ->
  #   @updater.updateEntityComponent(eid,type,atts)

  # Searches for Name components by name value, yields eid of each entity having such a Name component
  eachEntityNamed: (name,fn) ->
    res = @estore.search(Immutable.fromJS([{match: { type: 'name', name: name}, as: 'nameComp'}]))
    if fn?
      res.forEach (comps) ->
        fn(comps.getIn(['nameComp', 'eid']))
      return null
    else
      return res.map (comps) ->
        comps.getIn(['nameComp', 'eid'])

  firstEntityNamed: (name) ->
    return @eachEntityNamed(name).first()

  searchEntities: (filters) ->
    @estore.search(Immutable.fromJS(filters))




  #
  # EVENTS
  #

  getEvents: -> @eventBucket.getEventsForEntity(@eid())
  getEntityEvents: (eid) -> @eventBucket.getEventsForEntity(eid)

  publishEvent: (event,data=null) -> @eventBucket.addEventForEntity(@eid(),event,data)
  publishEntityEvent: (eid,event,data=null) -> @eventBucket.addEventForEntity(eid,event,data)

  publishGlobalEvent: (event,data=null) -> @eventBucket.addGlobalEvent(event,data)
  
  handleEvents: (handlerMap) ->
    @getEvents().forEach (e) ->
      handlerMap[e.get('name')]?(e.get('data'))

module.exports = BaseSystem
