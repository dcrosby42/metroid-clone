_ = require 'lodash'

nextId = (_gen) ->
  gen = {number: _gen.number, value: _gen.value, prefix: _gen.prefix}
  gen.number += 1
  gen.value = "#{gen.prefix}#{gen.number}"
  gen

filterComponent = (filter,comp) ->
  _.every filter, (val,key) ->
    comp[key] == val

filterComponents = (comps,filter,fn) ->
  _.forEach comps, (c, cid) ->
    if filterComponent(filter,c)
      fn c

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

  createEntity: (comps) ->
    eid = @newEntityId()
    _.forEach comps, (comp) =>
      @addComponent eid, comp
    [eid,comps]

  findComponents: (filters, fn) ->
    filter = filters[0]
    filterComponents @comps, filter, (comp) ->
      fn comp

  matchComponents: (filters, fn) ->

joinFind = (comps, filters, result, fn) ->
  filter = _.first(filters)
  remainingFilters = _.rest(filters)
  
  
  # filter.



# type = 'velocity' 
# eid = 0.eid
[ 'match', 'type', 'velocity' ]
[ 'match', 'eid', 0, 'eid' ]
        

module.exports = EntityStore




