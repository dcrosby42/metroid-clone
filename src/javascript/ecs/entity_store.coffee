IdSequenceGenerator = require './id_sequence_generator'

class EntityStore
  constructor: ->
    @eidGenerator = new IdSequenceGenerator(prefix: "e")
    @comps = {}

  _compsByType: (ctype) ->
    byEid = @comps[ctype]
    if !byEid?
      byEid = {}
      @comps[ctype] = byEid
    byEid

  newEntity: ->
    @eidGenerator.nextId()

  createEntity: (components) ->
    eid = @newEntity()
    for comp in components
      @addComponent eid, comp

  addComponent: (eid, comp) ->
    comp.eid = eid
    @_compsByType(comp.ctype)[eid] = comp

  removeComponent: (eid, comp) ->
    delete @_compsByType(comp.ctype)[eid]
    delete comp[eid]

  getComponent: (eid, ctype) ->
    @_compsByType(ctype)[eid]

  getComponentsOfType: (ctype) ->
    _.values @_compsByType(ctype)


module.exports = EntityStore
