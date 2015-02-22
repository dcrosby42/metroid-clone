_ = require 'lodash'
expect = require('chai').expect

EntityStore = require '../../src/javascript/ecs2/entity_store'

expectArray = (got,expected) ->
  expect(got.length).to.eq expected.length
  expect(got).to.deep.include.members(expected)

testFindComponents = (estore,filters,expected) ->
  found = []
  estore.findComponents filters, (c) -> found.push c
  expectArray found, expected

describe 'The new EntityStore', ->

  it 'should be', ->
    estore = new EntityStore()
    expect(estore).to.be

  describe 'adding and finding Components', ->

    it 'sets eid and cid', ->
      estore = new EntityStore()
      eid = estore.newEntityId()
      comp = {type: 'test-comp'}

      expect(comp.eid).to.be.undefined
      expect(comp.cid).to.be.undefined

      res = estore.addComponent eid, comp

      expect(res).to.eq(comp)
      expect(comp.eid).to.eq(eid)
      expect(comp.cid).to.be.a('string')

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

      testFindComponents estore, [{type: 'test-comp'}], [comp,comp2,comp3]
      testFindComponents estore, [{eid:eid, type:'test-comp'}], [comp,comp2]
      testFindComponents estore, [{eid:eid2, type:'test-comp'}], [comp3]

  describe 'createEntity', ->
    it 'generates a new entity composed of the given component data', ->
      estore = new EntityStore()
      [eid, [c1,c2]] = estore.createEntity [
        {type: 'type1', val1: 'abc'}
        {type: 'type2', val2: 'def'}
      ]
      expect(eid).to.be.a('string')
      expect(c1.eid).to.eq(eid)
      expect(c1.cid).to.be.a('string')
      expect(c1.val1).to.eq('abc')
      expect(c2.eid).to.eq(eid)
      expect(c2.cid).to.be.a('string')
      expect(c2.val2).to.eq('def')
      

  describe 'joins', ->

    it 'adds and finds components', ->
      estore = new EntityStore()

      [e1, [g1,v1]] = estore.createEntity [
        { type: 'gravity', x: 1, y: 1, telltale:'a' }
        { type: 'velocity', x: 11, y: 11 }]

      [e2, [g2,v2]] = estore.createEntity [
        { type: 'gravity', x: 2, y: 2, telltale:'b'}
        { type: 'velocity', x: 22, y: 22 }]

      [e3, [g3]] = estore.createEntity [
        { type: 'gravity', x: 3, y: 3 }]

      pairs = []
      estore.findComponents [ {type:'gravity'}, {type:'velocity'} ], (g,v) ->
        pairs.push [g,v]

      # expect(pairs.length).to.eq 2

  describe 'searching', ->
    it 'search1', ->
      c1 = { id: 1, name: 'Link', affil: 'good' }
      c2 = { id: 2, name: 'Zelda', affil: 'good' }
      c3 = { id: 3, name: 'Gannon', affil: 'bad' }
      c4 = { id: 4, name: 'Link', affil: 'bad' }

      comps = [c1,c2,c3,c4]

      filter1 = [
        ['match', 'name', 'Zelda']
      ]

      found1 = search1 comps, filter1
      expectArray found1, [c2]

      filter2 = [
        ['match', 'affil', 'good']
      ]
      found2 = search1 comps, filter2
      expectArray found2, [c1,c2]
      
      filter3 = [
        ['match', 'name', 'Link']
      ]
      found3 = search1 comps, filter3
      expectArray found3, [c1,c4]

      filter4 = [
        ['match', 'name', 'Link']
        ['match', 'affil', 'bad']
      ]
      found4 = search1 comps, filter4
      expectArray found4, [c4]

    it 'search2', ->
      c1 = { eid: 'e1', type: 'character', name: 'Link' }
      c2 = { eid: 'e1', type: 'bbox', shape: [1,2,3,4] }
      c3 = { eid: 'e2', type: 'character', name: 'Tektike' }
      c4 = { eid: 'e2', type: 'bbox', shape: [3,4,5,6] }

      comps = [c1,c2,c3,c4]

      filter1 = [
        ['match', 'type', 'character']
      ]
      filter2 = [
        ['match', 'type', 'bbox']
      ]

      found1 = search2 comps, [filter1,filter2]
      console.log found1
      expectArray found1, [
        [c1, c2]
        [c3, c4]
      ]


search1 = (comps,filter) ->
  _.filter comps, (c) ->
    _.every filter, (fil) ->
      switch fil[0]
        when 'match'
          c[fil[1]] == fil[2]

search2 = (comps,filters) ->
  rows = []
  # f1 = _.first(filters)
  # fs = _.rest(filters)
  f0 = filters[0]
  f1 = filters[1]

  rowx = []
  lcomps = search1(comps,f0)
  _.forEach lcomps, (lc) ->
    row = _.cloneDeep(rowx)
    row.push lc
    f1p = _.cloneDeep(f1)
    f1p.unshift ['match','eid',lc['eid']]
    # console.log "f1p modified w eid join:",f1p
    rcomps = search1(comps,f1p)
    _.forEach rcomps, (rc) ->
      row = _.cloneDeep(row)
      row.push rc
      rows.push row
      # rows.push [lc,rc]

  rows




      
