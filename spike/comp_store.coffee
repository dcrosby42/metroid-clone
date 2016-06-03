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
