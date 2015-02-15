_ = require 'lodash'

nextId = (_gen) ->
  gen = {number: _gen.number, value: _gen.value, prefix: _gen.prefix}
  gen.number += 1
  gen.value = "#{gen.prefix}#{gen.number}"
  gen

filterComponent = (filter,comp) ->
  _.every filter, (val,key) ->
    comp[key] == val

class EntityStore
  constructor: ->
    @eidGen = nextId(prefix:'e',number:0)
    @cidGen = nextId(prefix:'cmp',number:0)
    @comps = {}

  newEntityId: ->
    eid = @eidGen.value
    @eidGen = nextId(@eidGen)
    eid

  addComponent: (eid,comp) ->
    comp.eid = eid

    comp.cid = @cidGen.value
    @cidGen = nextId(@cidGen)

    @comps[comp.cid] = comp
    # @_updateIndices()
    comp

  findComponents: (filters, fn) ->
    filter = filters[0]
    _.forEach @comps, (c, cid) ->
      f = filterComponent(filter,c)
      if f
        fn c
        

module.exports = EntityStore




