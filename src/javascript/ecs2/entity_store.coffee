CompSet = require './comp_set'
Entity = require './entity'

EstNumberOfCompTypes = 50
CompSetInitialSize = 10
CompSetGrowSize = 10

class EntityStore
  constructor: ->
    @_nextCid = 1
    @_nextEid = 1
    @_initCompStorage()

  _initCompStorage: ->
    @_compsByType = new Array(EstNumberOfCompTypes)
    @_maxCompType = EstNumberOfCompTypes-1
    for _,i in @_compsByType
      @_compsByType[i] = new CompSet(CompSetInitialSize, CompSetGrowSize, "estore.compsByType[#{i}]")
    @_entities = {}


  _growCompsByType: (toAccommodateType=null) ->
    throw new Exception("EntityStore#_growCompsByType(toAccommodateType=#{toAccommodateType}): IMPLEMENT ME")

  _addComponent: (eid,comp) ->
    # console.log "EntityStore: Adding comp, nextCid=#{@_nextCid}",comp
    type = comp.type
    while type > @_maxCompType
      @_growCompsByType(type)
    compSet = @_compsByType[type]
    comp.eid = eid
    comp.cid = @_nextCid
    @_nextCid++
    # console.log "  EntityStore: comp cid=#{comp.cid} eid=#{comp.eid}"
    compSet.add(comp)
    return comp

  _deleteComponent: (comp) ->
    type = comp.type
    if type <= @_maxCompType
      compSet = @_compsByType[type]
      compSet.deleteByCid(comp.cid)
    else
      console.log "!! WARN EntityStore#deleteComponent can't delete comp of type #{type} because @_maxCompType=#{@_maxCompType}",comp
    null

  each: (type, fn) ->
    if type == null
      for compSet,t in @_compsByType
        compSet.each fn
      return null
      
    if type <= @_maxCompType
      @_compsByType[type].each fn
    else
      console.log "!! ERR EntityStore#eachComponentByType type=#{type} out of range!"
    null

  eachAndEveryComponent: (fn) ->
    for compSet,type in @_compsByType
      compSet.each fn

  createEntity: (comps=[]) ->
    eid = @_nextEid
    @_nextEid++
    entity = new Entity(@,eid)
    @_entities[eid] = entity
    for c in comps
      entity.addComponent(c)
    entity

  deleteEntityByEid: (eid) ->
    @_entities[eid].each null, (comp) =>
      @_deleteComponent(comp)
    delete @_entities[eid]
    null

  getEntity: (eid) ->
    @_entities[eid]

module.exports = EntityStore
