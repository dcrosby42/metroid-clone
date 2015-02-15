expect = require('chai').expect

EntityStore = require '../../src/javascript/ecs2/entity_store'

describe 'The new EntityStore', ->

  it 'should be', ->
    estore = new EntityStore()
    expect(estore).to.be

  describe 'adding and finding Components', ->

    # it 'sets eid and cid', ->
    #   res = estore.addComponent eid, comp
    #   expect(res).to.eq(comp)
    #   expect(comp.eid).to.eq(eid)
    #   expect(comp.cid).to.be.a('string')

    it 'adds and finds components', ->
      estore = new EntityStore()
      eid = estore.newEntityId()
      eid2 = estore.newEntityId()
      comp = {type: 'test-comp'}
      comp2 = {type: 'test-comp'}
      comp3 = {type: 'test-comp'}
      estore.addComponent eid, comp
      estore.addComponent eid, comp2
      estore.addComponent eid2, comp3

      found = []
      filter = { type: 'test-comp' }
      estore.findComponents [filter], (c) -> found.push c

      expect(found.length).to.eq 3
      expect(found).to.deep.include.members([comp,comp2,comp3])

      found2 = []
      filter2 = { eid: eid2, type: 'test-comp' }
      estore.findComponents [filter2], (c) -> found2.push c

      expect(found2.length).to.eq 1
      expect(found2).to.deep.include.members([comp3])
