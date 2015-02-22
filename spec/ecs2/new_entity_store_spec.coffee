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

  describe 'filterObjects', ->
    it 'works', ->
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

  describe 'joinObjects', ->
    it 'works', ->
      comps = makeZeldaComps()

      charFilter = [
        ['match', 'type', 'character']
      ]
      boxFilter = [
        ['join', 'eid']
        ['match', 'type', 'bbox']
      ]
      heroFilter = [
        ['join', 'eid']
        ['match', 'type', 'tag']
        ['match', 'value', 'hero']
      ]

      found1 = joinObjects comps, [charFilter, boxFilter]
      # console.log "RESULTS:",found1
      expectArray found1, [
        [comps[1], comps[2]]
        [comps[5], comps[6]]
      ]

      found2 = joinObjects comps, [charFilter,boxFilter,heroFilter]
      # console.log "RESULTS 2:",found2
      expectArray found2, [
        [comps[1], comps[2], comps[0]]
      ]

  describe 'joinObjects2', ->
    it 'works', ->
      comps = makeZeldaComps()

      charFilter =
        match: { type: 'character' }

      boxFilter =
        join: 'eid'
        match: { type: 'bbox' }

      heroFilter =
        join: 'eid'
        match: { type: 'tag', value: 'hero' }

      found1 = joinObjects2 comps, [charFilter, boxFilter]
      # console.log "RESULTS:",found1
      expectArray found1, [
        [comps[1], comps[2]]
        [comps[5], comps[6]]
      ]

      found2 = joinObjects2 comps, [charFilter,boxFilter,heroFilter]
      # console.log "RESULTS 2:",found2
      expectArray found2, [
        [comps[1], comps[2], comps[0]]
      ]

  describe 'expandFilter', ->
    it 'leaves arrays as they are', ->
      expectArray expandFilter([[]]), [[]]
      f2 = [
        ['match','something','interesting']
        ['a','b']
      ]
      expectArray expandFilter(f2), f2

    it 'turns a plain string into a "type matcher"', ->
      expectArray expandFilter('dude'), [['match','type','dude']]
      expectArray expandFilter('character'), [['match','type','character']]

    it 'turns a key:value into a key-value filter', ->
      expectArray expandFilter('hi:there'), [['match','hi','there']]
      expectArray expandFilter('type:dude'), [['match','type','dude']]

    it 'turns a tag:string into a "tag matcher"', ->
      expectArray expandFilter('tag:dude'), [['match','type','tag'],['match','value','dude']]
      expectArray expandFilter('tag:enemy'), [['match','type','tag'],['match','value','enemy']]
    it 'stops expanding', ->
      tagFilter = [['match','type','tag'],['match','value','enemy']]
      expectArray expandFilter('tag:enemy'), tagFilter
      expectArray expandFilter(expandFilter(expandFilter('tag:enemy'))), tagFilter


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

################################################################################################################################################
#
filterObjects = (comps,filter) ->
  _.filter comps, (c) ->
    _.every filter, (fil) ->
      c[fil[1]] == fil[2] # so far, 'match' is the ONLY kind of condition we support currently
      # TODO: to support different conditions, bring this switch statement back:
      # switch fil[0]
      #   when 'match'  #  [ 'match', key, val ]
      #     c[fil[1]] == fil[2]

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


##########################################################################################

filterObjects2 = (comps,filter) ->
  _.filter comps, _.matches(filter.match)
# filterObjects2 = (comps,filter) ->
#   _.filter comps, (c) ->
#     _.every filter.match, (val,key) ->
#       c[key] == val


joinObjects2 = (comps,filters,row=[]) ->
  # console.log "joinObjects2(comps,", filters, ",", row, ")"
  if filters.length == 0
    return [ row ]

  f0 = _.cloneDeep(_.first(filters))
  fs = _.rest(filters)

  if f0.join?
    if row.length > 0
      refObj = row[row.length-1]
      key = f0.join
      f0.match ||= {}
      f0.match[key] = refObj[key]
    
  rows = []
  _.forEach filterObjects2(comps,f0), (c) ->
    r = _.cloneDeep(row)
    r.push c
    _.forEach joinObjects2(comps,fs,r), (r2) ->
      rows.push r2
  rows


miniFormat = /\s*^(.+):(.+)\s*$/
expandFilter = (f) ->
  if _.isString(f)
    if ms = miniFormat.exec(f)
      switch ms[1]
        when 'tag'
          [
            ['match', 'type', 'tag']
            ['match', 'value', ms[2]]
          ]
        else
          [
            ['match', ms[1], ms[2]]
          ]
    else
      [ [ 'match', 'type', f ] ]
  else
    f


query =
  filters: [
    {
      match: { type: 'tag', value: 'hero' }
    }
    {
      match: { type: 'bbox' }
      join: 'eid'
    }
    {
      match: { type: 'character' }
      join: 'eid'
    }
  ]
console.log query
