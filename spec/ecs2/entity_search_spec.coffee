_ = require 'lodash'
chai = require('chai')
expect = chai.expect
assert = chai.assert

EntityStore = require '../../src/javascript/ecs2/entity_store'
EntitySearch = require '../../src/javascript/ecs2/entity_search'


C = require '../../src/javascript/components'
T = C.Types

class Fix
  constructor: ->
    @setupEntities()
    @setupFilters()

  setupEntities: ->
    @estore = new EntityStore()
    @e1 = @estore.createEntity([
      new C.Position(42,37)
      new C.Velocity(1,1)
      new C.Animation("samus","running")
      new C.HitBox(-5,5,-7,3)
    ])
    @e2 = @estore.createEntity([
      new C.Position(101,202)
      new C.Velocity(2,2)
      new C.Animation("skree","spinning")
      new C.Timer(3500,"explode")
      new C.HitBox(-5,5,-7,3)
    ])
    @e3 = @estore.createEntity([
      new C.Position(0.1,0.5)
      new C.Velocity(3,3)
      new C.Animation("fragment","normal")
      new C.Timer(250,"vanish")
      new C.Timer(100,"blink")
    ])

  setupFilters: ->
    @animFilter = new EntitySearch.filter(T.Animation)
    @posFilter = new EntitySearch.filter(T.Position)
    @velFilter = new EntitySearch.filter(T.Velocity)
    @hitboxFilter = new EntitySearch.filter(T.HitBox)
    @timerFilter = new EntitySearch.filter(T.Timer)

  runWithFilters: (filters) ->
    results = []
    EntitySearch.run @estore, EntitySearch.query(filters), (result) ->
      results.push copyArray(result.comps)
    results

copyArray = (arr) ->
  res = new Array(arr.length)
  for x,i in arr
    res[i] = x
  res

compListEquals = (cla,clb) ->
  diff = _.differenceWith(cla,clb,compEquals) 
  diff.length == 0

compEquals = (a,b) ->
  if !a?
    console.log "!! compEquals a is null"
    return false
  if !b?
    console.log "!! compEquals b is null"
    return false
  return a.equals(b)
 
assertResultComps = (gots,expects) ->
  diff1 = _.differenceWith(expects,gots,compListEquals)
  expect(diff1,"missing some expected comps #{JSON.stringify(diff1)}").to.be.empty
  diff2 = _.differenceWith(gots,expects,compListEquals)
  expect(diff2,"found extra comps #{JSON.stringify(diff2)}").to.be.empty



describe "EntitySearch", ->
  fix = null
  beforeEach ->
    fix = new Fix()
  afterEach ->
    fix = null
    
  describe "run()", ->

    it "executes a simple search", ->
      comps = fix.runWithFilters [fix.posFilter]
      assertResultComps comps, [
        [fix.e1.get(T.Position)]
        [fix.e2.get(T.Position)]
        [fix.e3.get(T.Position)]
      ]

    it "can match multiple comps per entity", ->
      comps = fix.runWithFilters [fix.posFilter,fix.velFilter]
      assertResultComps comps, [
        [fix.e1.get(T.Position),fix.e1.get(T.Velocity)]
        [fix.e2.get(T.Position),fix.e2.get(T.Velocity)]
        [fix.e3.get(T.Position),fix.e3.get(T.Velocity)]
      ]

    it "doesn't return comps from entities unless all filters are satisfied", ->
      comps = fix.runWithFilters [fix.posFilter,fix.velFilter,fix.hitboxFilter]
      assertResultComps comps, [
        [fix.e1.get(T.Position),fix.e1.get(T.Velocity),fix.e1.get(T.HitBox)]
        [fix.e2.get(T.Position),fix.e2.get(T.Velocity),fix.e2.get(T.HitBox)]
      ]

    it "protects from concurrent modification", ->
      comps = []
      EntitySearch.run fix.estore, EntitySearch.query([fix.timerFilter]), (result) ->
        result.entity.addComponent(new C.Timer(1,"added!"))
        comps.push copyArray(result.comps)
      expect(comps.length).to.equal(3)

      comps = []
      EntitySearch.run fix.estore, EntitySearch.query([fix.timerFilter]), (result) ->
        # result.entity.addComponent(new C.Timer(1,"added!"))
        comps.push copyArray(result.comps)
      expect(comps.length).to.equal(6)

  describe "runCompound()", ->
    it "produces a cartesian product of the results of each of its queries, MINUS combinations from the same entity", ->
      hitQ = EntitySearch.query([fix.hitboxFilter])
      pvQ = EntitySearch.query([fix.posFilter,fix.velFilter])
      cquery = EntitySearch.compoundQuery([hitQ,pvQ])
      entityCombinations = []
      EntitySearch.runCompound fix.estore, cquery, (hitRes, pvRes) ->
        entityCombinations.push [hitRes.entity.eid, pvRes.entity.eid]
      expect(entityCombinations).to.eql([
        # [ fix.e1.eid, fix.e1.eid ] # do not want
        [ fix.e1.eid, fix.e2.eid ]
        [ fix.e1.eid, fix.e3.eid ]
        [ fix.e2.eid, fix.e1.eid ]
        # [ fix.e2.eid, fix.e2.eid ] # do not want
        [ fix.e2.eid, fix.e3.eid ]
      ])

  describe "prepareSearcher", ->
    it "converts a list of comp types into a prepared searcher", ->
      searcher = EntitySearch.prepare([T.Position,T.Velocity])
      # comps = fix.runWithFilters [fix.posFilter,fix.velFilter]
      comps = []
      searcher.run fix.estore, (r) ->
        comps.push copyArray(r.comps)

      assertResultComps comps, [
        [fix.e1.get(T.Position),fix.e1.get(T.Velocity)]
        [fix.e2.get(T.Position),fix.e2.get(T.Velocity)]
        [fix.e3.get(T.Position),fix.e3.get(T.Velocity)]
      ]

    it "converts a list of lists of comp types into a prepared compound searcher", ->
      searcher = EntitySearch.prepare([
        [T.HitBox]
        [T.Position,T.Velocity]
      ])

      entityCombinations = []
      searcher.run fix.estore, (hitRes, pvRes) ->
        entityCombinations.push [hitRes.entity.eid, pvRes.entity.eid]

      expect(entityCombinations).to.eql([
        [ fix.e1.eid, fix.e2.eid ]
        [ fix.e1.eid, fix.e3.eid ]
        [ fix.e2.eid, fix.e1.eid ]
        [ fix.e2.eid, fix.e3.eid ]
      ])


        
# demo = (q) ->
#   console.log "======================="
#   console.log q.toString()
#   EntitySearch.run estore, q, (result) ->
#     console.log "Result e#{result.entity.eid}\n",result.comps
