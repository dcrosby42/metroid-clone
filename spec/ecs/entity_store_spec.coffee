expect = require('chai').expect

EntityStore = require '../../src/javascript/ecs/entity_store'

describe 'EntityStore', ->
  estore = new EntityStore()

  it 'should be', ->
    expect(estore).to.be

  describe '#newEntity', ->
    it 'generates a sequence of entity ids', ->
      eid1 = estore.newEntity()
      eid2 = estore.newEntity()
      eid3 = estore.newEntity()

      expect(eid1).to.match(/^e\d+/)
      expect(eid1).not.to.eq(eid2)
      expect(eid1).not.to.eq(eid3)
      expect(eid2).to.match(/^e\d+/)
      expect(eid2).not.to.eq(eid3)
      expect(eid3).to.match(/^e\d+/)

  describe 'adding and removing Components', ->
    eid = estore.newEntity()
    comp = {ctype: 'test-comp'}

    it 'registers a component by setting its eid', ->
      res = estore.addComponent eid, comp
      expect(res).to.eq(comp)
      expect(comp.eid).to.eq(eid)
      expect(estore.getComponent(eid,'test-comp')).to.eq(comp)





