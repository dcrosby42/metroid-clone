_ = require 'lodash'
chai = require('chai')
expect = chai.expect
assert = chai.assert

EntityStore = require '../../src/javascript/ecs2/entity_store'
EntitySearch = require '../../src/javascript/ecs2/entity_search'
TestHelpers = require './test_helpers'
{copyArray} = TestHelpers


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
      new C.Name("Ent One")
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
      new C.Animation("skree","disolving")
      new C.Timer(250,"vanish")
      new C.Timer(100,"blink")
      new C.Name("Ent Three")
    ])

  setupFilters: ->
    @animFilter = EntitySearch.filter(T.Animation)
    @posFilter = EntitySearch.filter(T.Position)
    @velFilter = EntitySearch.filter(T.Velocity)
    @hitboxFilter = EntitySearch.filter(T.HitBox)
    @timerFilter = EntitySearch.filter(T.Timer)

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

    it "can match component properties", ->
      entThreeFilter = EntitySearch.filter(T.Name,[['name','Ent Three']])
      comps = []
      EntitySearch.run fix.estore, EntitySearch.query([entThreeFilter]), (result) ->
        comps.push copyArray(result.comps)

      expect(comps).to.eql([
        [fix.e3.get(T.Name)]
      ])

      skreeFilter = EntitySearch.filter(T.Animation,[['spriteName','skree']])
      comps = []
      EntitySearch.run fix.estore, EntitySearch.query([fix.posFilter, skreeFilter]), (result) ->
        comps.push copyArray(result.comps)

      expect(comps).to.eql([
        [fix.e2.get(T.Position), fix.e2.get(T.Animation)]
        [fix.e3.get(T.Position), fix.e3.get(T.Animation)]
      ])

      skreeSpinFilter = EntitySearch.filter(T.Animation,[['spriteName','skree'],['state','spinning']])
      comps = []
      EntitySearch.run fix.estore, EntitySearch.query([fix.posFilter, skreeSpinFilter]), (result) ->
        comps.push copyArray(result.comps)

      expect(comps).to.eql([
        [fix.e2.get(T.Position), fix.e2.get(T.Animation)]
      ])
      


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

    it "converts objects into filters", ->
      searcher = EntitySearch.prepare([ {type:T.Position}, { type: T.Animation, spriteName: 'skree', state: 'spinning' } ])
      comps = []
      searcher.run fix.estore, (r) ->
        comps.push copyArray(r.comps)

      expect(comps).to.eql([
        [fix.e2.get(T.Position), fix.e2.get(T.Animation)]
      ])

  describe "expandFilter", ->
    expandFilter = EntitySearch._expandFilter

    it "returns simple filter if given a valid component type", ->
      expect(expandFilter(T.Animation)).to.eql(EntitySearch.filter(T.Animation))
      expect(expandFilter(T.Name)).to.eql(EntitySearch.filter(T.Name))

    it "returns simple filter if given an object with a type prop", ->
      expect(expandFilter({type: T.Animation})).to.eql(EntitySearch.filter(T.Animation))
      expect(expandFilter({type: T.Name})).to.eql(EntitySearch.filter(T.Name))
      
    it "returns filter with matches if given an object with a type prop and extra keys", ->
      expanded = expandFilter({type: T.Name, name: "axel"})
      expect(expanded).to.eql(EntitySearch.filter(T.Name,[['name','axel']]))
      # and drops superfluous attrs:
      expanded = expandFilter({type: T.Name, name: "rose",extran:"eous"})
      expect(expanded).to.eql(EntitySearch.filter(T.Name,[['name','rose']]))

    it "returns filters that are already expanded", ->
      expect(expandFilter(fix.animFilter)).to.eql(fix.animFilter)

    it "returns null if given crap", ->
      # console.log expandFilter(-1)
      expect(expandFilter(-1)).to.be.null
      expect(expandFilter(12345)).to.be.null
      expect(expandFilter(null)).to.be.null
      expect(expandFilter("dude")).to.be.null
      expect(expandFilter({what:"evar"})).to.be.null



        
# demo = (q) ->
#   console.log "======================="
#   console.log q.toString()
#   EntitySearch.run estore, q, (result) ->
#     console.log "Result e#{result.entity.eid}\n",result.comps
