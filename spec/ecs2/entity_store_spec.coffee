_ = require 'lodash'
chai = require('chai')
expect = chai.expect
assert = chai.assert

EntityStore = require '../../src/javascript/ecs2/entity_store'
C = require '../../src/javascript/components'
T = C.Types
buildComp = C.buildCompForType

TestHelpers = require './test_helpers'
{copyArray, compListEquals, assertResultComps} = TestHelpers

describe "EntityStore", ->
  describe "clone()", ->
    pos1 = pos2 = vel1 = tag1 = e1 = e2 = target = null
    beforeEach ->
      target = new EntityStore()
      pos1 = buildComp T.Position, x: 1, y: 10
      pos2 = buildComp T.Position, x: 2, y: 20
      vel1 = buildComp T.Velocity, x: 30, y: 30
      tag1 = buildComp T.Tag, name: 'aTag'
      e1 = target.createEntity [pos1,vel1]
      e2 = target.createEntity [pos2,tag1]

    it "copies all the components", ->
      comps1 = []
      target.eachAndEveryComponent (comp)-> comps1.push comp

      cloned = target.clone()
      comps2 = []
      cloned.eachAndEveryComponent (comp)-> comps2.push comp

      expect(compListEquals(comps1,comps2)).to.be.true

    it "copies all the entities", ->
      cloned = target.clone()
      clonedEids = []
      clonedComps = {}
      for eid,ent of cloned._entities
        clonedEids.push eid
        ent.each null, (comp) ->
          clonedComps[eid] ?= []
          clonedComps[eid].push comp

      targetEids = []
      targetComps = {}
      for eid,ent of target._entities
        targetEids.push eid
        ent.each null, (comp) ->
          targetComps[eid] ?= []
          targetComps[eid].push comp

      expect(clonedEids).to.eql(targetEids)
      expect(clonedComps).to.eql(targetComps)

    it "sets internal state properly", ->
      cloned = target.clone()
      expect(cloned._nextCid).to.equal(target._nextCid)
      expect(cloned._nextEid).to.equal(target._nextEid)
      expect(cloned._maxCompType).to.equal(target._maxCompType)

    it "doesn't modify components from the original", ->
      cloned = target.clone()
      clonedTag = null
      cloned.each T.Tag, (comp) ->
        comp.name = "modified"
        clonedTag = comp

      expect(tag1.name).to.equal('aTag')
      expect(clonedTag.name).to.equal('modified')

    it "doesn't add components in the original Entity or EntityStore", ->
      cloned = target.clone()
      clonedE2 = cloned.getEntity(e2.eid)
      newVel = buildComp T.Velocity, x:42,y:42
      clonedE2.addComponent newVel
      
      # See newVel was added in cloned e2
      clonedE2vels = []
      clonedE2.each T.Velocity, (comp) -> clonedE2vels.push(comp)
      expect(compListEquals(clonedE2vels,[newVel])).to.be.true

      # See newVel NOT added to original e2
      origE2vels = []
      e2.each T.Velocity, (comp) -> origE2vels.push(comp)
      expect(origE2vels.length).to.equal(0)
      
      # See newVel NOT added to original target
      # (This test proves the cloned entities were given the right estore reference, ie, the cloned estore and not the original)
      targetVels = []
      target.each T.Velocity, (comp) -> targetVels.push(comp)
      expect(targetVels.length).to.equal(1,"target velocity comp set length changed!")
      expect(compListEquals(targetVels,[vel1])).to.be.true

    it "doesn't (through cloned Entities) delete components in the original Entity or EntityStore", ->
      cloned = target.clone()
      clonedE2 = cloned.getEntity(e2.eid)
      clonedTag = clonedE2.get(T.Tag)
      clonedE2.deleteComponent(clonedTag)
      
      # See tag removed from cloned e2
      clonedE2Tags = []
      clonedE2.each T.Tag, (comp) -> clonedE2Tags.push(comp)
      expect(clonedE2Tags.length).to.equal(0)

      # See tag NOT removed from original e2 entity
      origE2Tags = []
      e2.each T.Tag, (comp) -> origE2Tags.push(comp)
      expect(compListEquals(origE2Tags,[tag1])).to.be.true
      
      # See newVel NOT added to original target
      # (This test proves the cloned entities were given the right estore reference, ie, the cloned estore and not the original)
      targetTags = []
      target.each T.Tag, (comp) -> targetTags.push(comp)
      expect(targetTags.length).to.equal(1,"target tag comp set length changed!")
      expect(compListEquals(targetTags,[tag1])).to.be.true

    it "doesn't add entities to the original EntityStore", ->
      cloned = target.clone()
      tag2 = buildComp T.Tag, name: "second tag"
      cloned.createEntity [tag2]

      expect(cloned._entities[3],"should be entity 3 in cloned").to.exist
      expect(target._entities[3],"should NOT be entity 3 in target").to.not.exist

      # See the tag was added in cloned
      clonedTags = []
      cloned.each T.Tag, (comp) -> clonedTags.push(comp)
      expect(compListEquals(clonedTags,[tag1,tag2])).to.be.true

      # See the tag was NOT added in cloned
      origTags = []
      target.each T.Tag, (comp) -> origTags.push(comp)
      expect(compListEquals(origTags,[tag1])).to.be.true

    it "doesn't remove entities from the original EntityStore", ->
      cloned = target.clone()

      cloned.deleteEntityByEid(e2.eid)
      expect(cloned.getEntity(e2.eid)).to.not.exist
      expect(target.getEntity(e2.eid)).to.exist

      # See the comps for e2 are gone from cloned
      clonedComps = []
      cloned.eachAndEveryComponent (comp) -> clonedComps.push(comp)
      expect(compListEquals(clonedComps,[pos1,vel1])).to.be.true

      # See the comps for e2 are still in target
      origComps = []
      target.eachAndEveryComponent (comp) -> origComps.push(comp)
      expect(compListEquals(origComps,[pos1,vel1,pos2,tag1])).to.be.true
