Types = require './domain'
C = require './components'

# Entity Store stuff:
# eidGen
# cidGen
# takeSnapshot 
# getComponent(cid)
# getEntityComponent(eid,type)
# getEntityComponents(eid,type)
# forEachComponent(fn)
# search(filters)
#
# createComponent(eid,props)
# deleteComponent(comp)
# createEntity(listOfCompProps)
# destroyEntity(eid)

debugln = console.log
debug = true

EstNumberOfCompTypes = 50
InitialCompListSize = 10

class CompSet
  constructor: (@initSize=20,@growSize=10) ->
    @comps = new Array(@initSize)
    for _,i in @comps
      @comps[i] = null
    @length = @initSize
    @count = 0

  add: (comp) ->
    if @count < @length
      for c,i in @comps
        if !c?
          @comps[i] = comp
          @count++
          break
    else
      newLen = @length + @growSize
      upsized = new Array(newLen)
      for comp,i in @comps
        upsized[i] = comp
      upsized[@length] = comp
      @count++
      i = @length+1
      while i < newLen
        upsized[i] = null
        i++
      @comps = upsized
      @length = newLen

  each: (fn) ->
    for c in @comps
      if c?
        fn(c)

  single: ->
    for c in @comps
      if c?
        if @count != 1
          console.log "!! WARNING CompSet#single returning component 1 of #{@count}",c
        return c

    console.log "!! WARNING CompSet#single returning null"
    return null

  getByCid: (cid) ->
    for c in @comps
      if c? and c.cid == cid
        return c

  deleteByCid: (cid) ->
    for c,i in @comps
      if c? and c.cid == cid
        @comps[i] = null
        @count -= 1

  
class EntityStore
  constructor: ->
    @_nextCid = 1
    @_nextEid = 1
    @_initCompStorage()

  _initCompStorage: ->
    @_compsByType = new Array(EstNumberOfCompTypes)
    @_maxCompType = EstNumberOfCompTypes-1
    for _,i in @_compsByType
      @_compsByType[i] = new CompSet(5,10)
    # @_compsByCid = {}
    @_entities = {}


  _growCompsByType: (toAccommodateType=null) ->
    throw new Exception("EntityStore#_growCompsByType(toAccommodateType=#{toAccommodateType}): IMPLEMENT ME")

  _addComponent: (eid,comp) ->
    type = comp.constructor.type
    while type > @_maxCompType
      @_growCompsByType(type)
    compSet = @_compsByType[type]
    comp.eid = eid
    comp.cid = @_nextCid
    @_nextCid += 1
    compSet.add(comp)
    # @_entities[comp.eid]._addComponent(comp)
    # @_compsByCid[comp.cid] = comp
    return comp

  _deleteComponent: (comp) ->
    type = comp.constructor.type
    if type <= @_maxCompType
      compSet = @_compsByType[type]
      compSet.deleteByCid(comp.cid)
      # delete @_compsByCid[comp.cid]
      # comp.cid = null
      # comp.eid = null
    else
      console.log "!! WARN EntityStore#deleteComponent can't delete comp of type #{type} because @_maxCompType=#{@_maxCompType}",comp
    null

  eachComponentByType: (type, fn) ->
    if type <= @_maxCompType
      @_compsByType[compType].each fn
    else
      console.log "!! ERR EntityStore#eachComponentByType type=#{type} out of range!"
    null

  eachComponent: (fn) ->
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
    @_entities[eid].eachComponent (comp) ->
      @deleteComponent(comp)
    delete @_entities[eid]
    null

  getEntity: (eid) ->
    @_entities[eid]

class Entity
  constructor: (@estore,@eid) ->
    @_compTypes = new Array(10)
    @_compTypesI = 0
    
  eachComponent: (fn) ->
    for ct in @_compTypes
      @[ct].each fn

  addComponent: (comp) ->
    @estore._addComponent(@eid,comp)
    type = comp.constructor.type
    @[type] ?= new CompSet(2,5)
    @[type].add(comp)
    @_trackCompType(type)
    null
    
  deleteComponent: (comp) ->
    type = comp.constructor.type
    compSet = @[type]
    if compSet?
      compSet.deleteByCid(comp.cid)
    null

  delete: ->
    @eachComponent (comp) ->
      @deleteComponent(comp)
    null

  _trackCompType: (type) ->
    i = 0
    while i < @_compTypesI
      return if @_compTypes[i] == type
      i++
    len = @_compTypes.length
    if @_compTypesI >= len
      upsized = new Array(len+5)
      for t,i in @_compTypes
        upsized[i] = t
      @_compTypes = upsized
      @_compTypesI = len
    @_compTypes[@_compTypesI] = type
    @_compTypesI++
    null
      

estore = new EntityStore()

e1 = estore.createEntity([
  new C.Position(10,20)
  new C.Animation("samus","standing")
  new C.Animation("samus","jumping")
])

e2 = estore.createEntity([
  new C.Position(42,37)
  new C.Animation("piper","piping")
])

# console.log estore
# console.log estore._entities[1]

# estore.eachComponent (c) ->
#   console.log c
# console.log estore.getEntity(e2)[C.Position.type].single()
estore.getEntity(e1)[C.Animation.type].each (x) -> console.log x

# TODO FIX CompSet starting-at-size-1 bug
