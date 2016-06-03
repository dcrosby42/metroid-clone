
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

module.exports = Domain

