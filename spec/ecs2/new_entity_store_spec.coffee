_ = require 'lodash'
Immutable = require 'immutable'
chai = require('chai')
expect = chai.expect
assert = chai.assert

EntityStore = require '../../src/javascript/ecs2/entity_store'

expectArray = (got,expected) ->
  expect(got.length).to.eq expected.length
  expect(got).to.deep.include.members(expected)

expectIs = (actual,expected) ->
  if !Immutable.is(actual,expected)
    assert.fail(actual,expected,"Immutable structures not equal.\nExpected: #{expected.toString()}\n  Actual: #{actual.toString()}")

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

  describe 'filterObjects', ->
    it 'works', ->
      c1 = Immutable.fromJS id: 1, name: 'Link', affil: 'good'
      c2 = Immutable.fromJS id: 2, name: 'Zelda', affil: 'good'
      c3 = Immutable.fromJS id: 3, name: 'Gannon', affil: 'bad'
      c4 = Immutable.fromJS id: 4, name: 'Link', affil: 'bad'

      comps = Immutable.List([c1,c2,c3,c4])

      filter1 = Immutable.fromJS match: { name: 'Zelda' }
      found1 = filterObjects comps, filter1
      expectIs found1, Immutable.List([c2])
  
      filter2 = Immutable.fromJS { match: { affil: 'good' } }
      found2 = filterObjects comps, filter2
      expectIs found2, Immutable.List [c1,c2]
 
      filter3 = Immutable.fromJS { match: { name: 'Link' } }
      found3 = filterObjects comps, filter3
      expectIs found3, Immutable.List [c1,c4]
  
      filter4 = Immutable.fromJS
        match:
          name: 'Link'
          affil: 'bad'

      found4 = filterObjects comps, filter4
      expectIs found4, Immutable.List [c4]

  describe 'joinObjects', ->
    it 'works with immutable objects', ->
      compsJS = makeZeldaComps()
      comps = Immutable.fromJS(compsJS)
      # comps = Immutable.List(compsJS) # Makes an immutable list of regular mutable JS objects

      charFilter = Immutable.fromJS
        match: { type: 'character' }
        as: 'char'

      boxFilter = Immutable.fromJS
        join: 'char.eid'
        match: { type: 'bbox' }
        as: 'box'

      heroFilter = Immutable.fromJS
        join: 'box.eid'
        match: { type: 'tag', value: 'hero' }
        as: 'hero'

      found1 = joinObjects comps, Immutable.fromJS([charFilter, boxFilter])
      # console.log "RESULTS:",found1
      expectIs found1, Immutable.fromJS [
        { char: comps.get(1), box: comps.get(2) }
        { char: comps.get(5), box: comps.get(6) }
      ]

      found2 = joinObjects comps, Immutable.fromJS([charFilter,boxFilter,heroFilter])
      # console.log "RESULTS 2:",found2
      expectIs found2, Immutable.fromJS [
        {char: comps.get(1), box: comps.get(2), hero: comps.get(0) }
      ]

    it 'works with normal (mutable) objects', ->
      compsJS = makeZeldaComps()
      # comps = Immutable.fromJS(compsJS)
      comps = Immutable.List(compsJS) # Makes an immutable list of regular mutable JS objects

      charFilter = Immutable.fromJS
        match: { type: 'character' }
        as: 'char'

      boxFilter = Immutable.fromJS
        join: 'char.eid'
        match: { type: 'bbox' }
        as: 'box'

      heroFilter = Immutable.fromJS
        join: 'box.eid'
        match: { type: 'tag', value: 'hero' }
        as: 'hero'

      found1 = joinObjects comps, Immutable.fromJS([charFilter, boxFilter])
      console.log "RESULTS:",found1
      expect(found1.size).to.eq(2)
      expectIs found1, Immutable.List [
        Immutable.Map( char: comps.get(1), box: comps.get(2) )
        Immutable.Map( char: comps.get(5), box: comps.get(6) )
      ]

      found2 = joinObjects comps, Immutable.fromJS([charFilter,boxFilter,heroFilter])
      # console.log "RESULTS 2:",found2
      expect(found2.size).to.eq(1)
      expectIs found2, Immutable.List [
        Immutable.Map(char: comps.get(1), box: comps.get(2), hero: comps.get(0) )
      ]


makeZeldaComps = ->
  [
    { eid: 'e1', type: 'tag', value: 'hero' }
    { eid: 'e1', type: 'character', name: 'Link' }
    { eid: 'e1', type: 'bbox', shape: [1,2,3,4] }
    { eid: 'e1', type: 'inventory', stuff: 'items' }

    { eid: 'e1', type: 'tag', value: 'enemy' }
    { eid: 'e2', type: 'character', name: 'Tektike' }
    { eid: 'e2', type: 'bbox', shape: [3,4,5,6] }
    { eid: 'e2', type: 'digger', status: 'burrowing' }
  ]


  
filterObjects = (comps,filter) ->
  matchProps = filter.get('match')

  comps.filter (obj) ->
    if Immutable.Map.isMap(obj)
      obj.isSuperset(matchProps)
    else
      _.matches(matchProps.toJS())(obj)

  # cs = _.filter comps, _.matches(matchProps)
  # Immutable.fromJS(cs)

joinObjects = (comps,filters,row=Immutable.Map()) ->
  # console.log "joinObjects(comps,",filters,",",row,")"
  if filters.size == 0
    return Immutable.List([row])

  f0 = convertJoins(filters.first(),row)
  fs = filters.shift()

    
  as = f0.get('as')
  filterObjects(comps,f0).map((c) ->
    joinObjects(comps,fs,row.set(as,c))
  ).flatten(1)
 

convertJoins = (filter,row) ->
  join = filter.get('join')
  if join?
    [refKey,key] = join.split('.')
    refObj = row.get(refKey)
    if refObj
      val = if Immutable.Map.isMap(refObj)
        refObj.get(key)
      else
        refObj[key]

      if val?
        filter.setIn ['match',key], val
      else
        filter
    else
      filter
  else
    filter









################################
query =
  filters: [
    {
      match: { type: 'tag', value: 'hero' }
      as: 'tag'
    }
    "bbox"
    {
      match: { type: 'bbox' }
      join: 'eid'
      as: 'bbox'
    }
    {
      match: { type: 'character' }
      join: 'eid'
      as: 'char'
    }
  ]
# console.log query


# searchComponents comps, ["character", "bbox", "tag:hero"]
