EntityStore = require '../../src/javascript/ecs2/entity_store'
EntitySearch = require '../../src/javascript/ecs2/entity_search'

C = require '../../src/javascript/components'


chai = require('chai')
expect = chai.expect
assert = chai.assert

# expand [ Position,Velocity ] =>
# [
#    { compType: Position }
#    { compType: Velocity }
# ]

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

anim = new EntitySearch.Filter(C.Animation.type)
pos = new EntitySearch.Filter(C.Position.type)
vel = new EntitySearch.Filter(C.Velocity.type)
hit = new EntitySearch.Filter(C.HitBox.type)
timer = new EntitySearch.Filter(C.Timer.type)


demo = (q) ->
  console.log "======================="
  console.log q.toString()
  EntitySearch.run estore, q, (result) ->
    console.log "Result e#{result.entity.eid}\n",result.comps

demo new EntitySearch.Query([anim,timer])
demo new EntitySearch.Query([pos,vel,hit])
demo new EntitySearch.Query([hit,hit,hit])

cquery = new EntitySearch.CompoundQuery([
  new EntitySearch.Query([anim,timer])
  new EntitySearch.Query([pos,vel,hit])
])

console.log "======================="
console.log cquery.toString()
EntitySearch.runCompound estore, cquery, (a,b) ->
    console.log "Compound Result [A: e#{a.entity.eid}, B: e#{b.entity.eid}]"
    console.log "A:\n",a.comps
    console.log "B:\n",b.comps





# EntitySearch.CompoundQuery([f1

# console.log "======================="
# EntitySearch.run estore, query, (result) ->
#    console.log "RESULT e#{result.entity.eid}",result.comps

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
