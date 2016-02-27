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

  update: (estore, input, eventBucket) ->
    @estore = estore
    @input = input
    @eventBucket = eventBucket
    estore.search(@componentFilters).forEach (comps) =>
      @comps = comps

      @resetCache()
      @process()
      @sync()
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

  sync: ->
    for name in @updatedCompNames
      @estore.updateComponent @updatedComps[name]
    for comp in @compsToDelete
      @estore.deleteComponent comp
    for [eid,props] in @compsToAdd
      @estore.createComponent eid, props
    for comps in @entitiesToAdd
      @estore.createEntity comps
    for eid in @entitiesToDelete
      @estore.destroyEntity eid

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
    res = @estore.search([{match: { type: 'name', name: name}, as: 'nameComp'}])
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
    @estore.search(filters)




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
