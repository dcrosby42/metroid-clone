
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


module.exports = Domain

