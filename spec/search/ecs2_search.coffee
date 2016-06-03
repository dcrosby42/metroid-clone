Filter = require '../../src/javascript/ecs2/filter'
EntityStore = require '../../src/javascript/ecs2/entity_store'
C = require '../../src/javascript/components'

# Immutable = require 'immutable'

chai = require('chai')
expect = chai.expect
assert = chai.assert


# runSearch = (estore, search, fn, slot=0,result=null) ->
#     result =? search.result()
#     f = search.filters[slot]

    # source = null
    # if f.compType?
    #   source = estore
    # else if f.eid?
    #   source = estore.getEntity(f.eid)
    #   if !source?
    #     console.log "!! ERROR runSearch: filter specifies eid=#{eid} but estore contains no such entity"
    #     return

    # source.each f.compType, (comp) ->
    #   result[slot] = comp
    #   slot++
    #   if slot >= search.width
    #     fn(result)
    #   else
    #     runSearch(estore,search,fn,slot,result)

# expand [ Position,Velocity ] =>
# [
#    { compType: Position }
#    { compType: Velocity }
# ]
runEntitySearch = (estore,esearch,handler) ->
  result = esearch.newResult()
  slot = 0
  filter = esearch.filters[slot]  # TODO: handle empty filters
  if filter.compType?
    estore.each filter.compType, (comp) ->
      # TODO: dedupe this
      result.entity = estore.getEntity(comp.eid) # THIS LINE IS NOT DUPED IN run2
      result.comps[slot] = comp
      nextSlot = slot+1
      if nextSlot == result.width
        handler(result)
      else
        runEntitySearch2(estore,esearch,handler,nextSlot,result)
  else
    console.log "!! EntitySearch TODO: support entity searches without compType"
  # TODO: support filter.eid right off the bat?
  result.comps[slot] = null

runEntitySearch2 = (estore,esearch,handler,slot,result) ->
  filter = esearch.filters[slot]
  if filter.compType?
    result.entity.each filter.compType, (comp) ->
      # TODO: dedupe this
      result.comps[slot] = comp
      nextSlot = slot+1
      if nextSlot == result.width
        handler(result)
      else
        runEntitySearch2(estore,esearch,handler,nextSlot,result)
  else
    console.log "!! EntitySearch.run2 TODO: support entity searches without compType"
  result.comps[slot] = null

  # TODO: support "left join" situations, ie, filter steps that are acceptable to miss


class EntitySearch
  constructor: (@filters) ->
    @width = @filters.length
    @_result = new EntitySearchResult(@width)

  newResult: ->
    return new EntitySearchResult(@width)

class EntitySearchResult
  constructor: (@width) ->
    @entity = null
    @comps = new Array(@width)

  backupTo: (slot) ->

  # rese
  #   @entity = null
  #   i = 0
  #   while i < @width
  #     @comps[i] = null
  #   return @


# describe "monkeying around", ->
#   it "works", ->

estore = new EntityStore()
# e1 = estore.createEntity()
# e1.addComponent(new C.Position(42,37))
# e1.addComponent(new C.Animation("samus","running"))
e1 = estore.createEntity([
  new C.Position(42,37)
  new C.Velocity(1,1)
  new C.Animation("samus","running")
  new C.HitBox(-5,5,-7,3)
])
e2 = estore.createEntity([
  new C.Position(101,202)
  new C.Velocity(2,2)
  new C.Animation("skree","spinning")
  new C.Timer(3500,"explode")
  new C.HitBox(-5,5,-7,3)
])
e3 = estore.createEntity([
  new C.Position(0.1,0.5)
  new C.Velocity(3,3)
  new C.Animation("fragment","normal")
  new C.Timer(250,"vanish")
  new C.Timer(100,"blink")
])

f1 = new Filter(C.Position.type)
f2 = new Filter(C.Velocity.type)
f3 = new Filter(C.HitBox.type)
f4 = new Filter(C.Timer.type)
filters = [f1,f4]
search = new EntitySearch(filters)

i=0
runEntitySearch estore, search, (result) ->
  console.log "RESULT e#{result.entity.eid}",result.comps
  result.entity.addComponent(new C.Timer(i,"ADDED TIMER"))
  i++

console.log "======================="
runEntitySearch estore, search, (result) ->
  console.log "RESULT e#{result.entity.eid}",result.comps

console.log "======================="

search = new EntitySearch([f3,f3,f3])

runEntitySearch estore, search, (result) ->
  console.log "RESULT e#{result.entity.eid}",result.comps


console.log "======================="
runEntitySearch estore, search, (result) ->
   console.log "RESULT e#{result.entity.eid}",result.comps

# ent = estore.getEntity(e3.eid)
# console.log ent
# ent.each C.Velocity.type, (c) ->
#   console.log c

# console.log e1.get(C.Position.type)
# console.log e1.get(C.Animation.type)
    # estore.each null, (c) ->
    #   console.log c, c.type
    # f = new Filter('pos', C.Position.type, 42,null)
    # console.log f
    # expect(1).to.eql(1)
