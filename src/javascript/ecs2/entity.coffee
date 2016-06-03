CompSet = require './comp_set'

CompSetInitialSize = 10
CompSetGrowSize = 10

module.exports = class Entity
  constructor: (@estore,@eid) ->
    @_compTypes = new Array(10)
    @_compTypesI = 0
    
  get: (type) ->
    @[type]?.single(type)

  getList: (type) ->
    compSet = @[type]
    if compSet?
      arr = new Array(compSet.count)
      i = 0
      compSet.each (c) ->
        arr[i] = c
        i++
      return arr

  each: (type,fn) ->
    if type == null
      for ct in @_compTypes
        @[ct]?.each fn
    else
      @[type]?.each fn
    null

  addComponent: (comp) ->
    @estore._addComponent(@eid,comp)
    type = comp.type
    @[type] ?= new CompSet(CompSetInitialSize,CompSetGrowSize,"e#{@eid}-type#{type}")
    @[type].add(comp)
    @_trackCompType(type)
    null
    
  deleteComponent: (comp) ->
    type = comp.type
    @[type]?.deleteByCid(comp.cid)
    @estore._deleteComponent(comp)
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
      
