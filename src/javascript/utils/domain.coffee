
class Domain
  constructor: (@name) ->
    @constructor[@name] = @
    @nextId = 0
    @typeIdsToNames = {}
    @typeIdsToClasses = {}

  registerClass: (clazz) ->
    tid = @nextId
    @nextId++
    @typeIdsToNames[tid] = clazz.name
    @typeIdsToClasses[tid] = clazz
    @[clazz.name] = tid
    clazz.type = tid
    tid
  
  nameFor: (typeId) ->
    name = @typeIdsToNames[typeId]
    if !name?
      console.log "!! Domain[#{@name}]: name requested for unknown typeId #{typeId}"
      name = "UNKNOWN-COMP-TYPE-#{typeId}"
    name

  classFor: (typeId) ->
    clazz = @typeIdsToClasses[typeId]
    if !clazz?
      console.log "!! Domain[#{@name}]: class requested for unknown typeId #{typeId}"
    clazz

  exists: (typeId) ->
    @typeIdsToClasses[typeId]?

  printTypeNames: ->
    console.log "Types in Domain #{@name}:"
    for typeId,name of @typeIdsToNames
      console.log "  #{typeId}: #{name}"



module.exports = Domain

