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
    it 'filterObjects', ->
      c1 = { id: 1, name: 'Link', affil: 'good' }
      c2 = { id: 2, name: 'Zelda', affil: 'good' }
      c3 = { id: 3, name: 'Gannon', affil: 'bad' }
      c4 = { id: 4, name: 'Link', affil: 'bad' }

      comps = [c1,c2,c3,c4]

      filter1 = [
        ['match', 'name', 'Zelda']
      ]

      found1 = filterObjects comps, filter1
      expectArray found1, [c2]

      filter2 = [
        ['match', 'affil', 'good']
      ]
      found2 = filterObjects comps, filter2
      expectArray found2, [c1,c2]
      
      filter3 = [
        ['match', 'name', 'Link']
      ]
      found3 = filterObjects comps, filter3
      expectArray found3, [c1,c4]

      filter4 = [
        ['match', 'name', 'Link']
        ['match', 'affil', 'bad']
      ]
      found4 = filterObjects comps, filter4
      expectArray found4, [c4]

    it 'joinObjects', ->
      t1 = { eid: 'e1', type: 'tag', value: 'hero' }
      c1 = { eid: 'e1', type: 'character', name: 'Link' }
      c2 = { eid: 'e1', type: 'bbox', shape: [1,2,3,4] }
      c3 = { eid: 'e2', type: 'character', name: 'Tektike' }
      c4 = { eid: 'e2', type: 'bbox', shape: [3,4,5,6] }
      c5 = { eid: 'e1', type: 'other', stuff: 'items' }
      c6 = { eid: 'e2', type: 'other', stuff: 'things' }

      comps = [t1,c1,c2,c3,c4,c5,c6]

      filter1 = [
        ['match', 'type', 'character']
      ]
      filter2 = [
        ['join', 'eid']
        ['match', 'type', 'bbox']
      ]
      filter3 = [
        ['join', 'eid']
        ['match', 'type', 'tag']
        ['match', 'value', 'hero']
      ]

      found1 = joinObjects comps, [filter1,filter2]
      console.log "RESULTS:",found1
      expectArray found1, [
        [c1, c2]
        [c3, c4]
      ]

      found2 = joinObjects comps, [filter1,filter2,filter3]
      console.log "RESULTS 2:",found2
      expectArray found2, [
        [c1, c2, t1]
      ]


filterObjects = (comps,filter) ->
  _.filter comps, (c) ->
    _.every filter, (fil) ->
      c[fil[1]] == fil[2] # so far, 'match' is the ONLY kind of condition we support currently
      # TODO: to support different conditions, bring this switch statement back:
      # switch fil[0]
      #   when 'match'  #  [ 'match', key, val ]
      #     c[fil[1]] == fil[2]

joinComponents = (comps,filters) ->
  filters2 = _.cloneDeep(filters)
  _.forEach _.rest(filters2), (f) ->
    f.unshift [ 'join', 'eid' ]
  joinObjects comps,filters2

joinObjects = (comps,filters,row=[]) ->
  if filters.length == 0
    return [ row ]

  f0 = _.cloneDeep(_.first(filters))
  fs = _.rest(filters)

  _.forEach f0, (cond) ->
    switch cond[0]
      when 'join'
        if row.length > 0
          lobj = row[row.length-1]
          cond[0] = 'match'
          # cond[1] remains the specified key, such as 'eid'
          cond[2] = lobj[cond[1]]  # eg, converts [ 'join', 'eid' ] into [ 'match', 'eid', lc['eid'] ]
        # TODO maybe this isn't an error after all? Would it be convenient to allow ALL filters to have a join condition?
        # else
        #   console.log "!! ERROR: join condition found, but no left-hand object to match on? Condition:",cond

  rows = []
  _.forEach filterObjects(comps,f0), (c) ->
    r = _.cloneDeep(row)
    r.push c
    _.forEach joinObjects(comps,fs,r), (r2) ->
      rows.push r2
  rows



      
