chai = require('chai')
expect = chai.expect
assert = chai.assert

CompSet = require '../../src/javascript/ecs2/comp_set'
C = require '../../src/javascript/components'
T = C.Types
{Position} = C

newPosition = (x,y,eid,cid) ->
  pos = C.buildCompForType T.Position, {
    x: x
    y: y
  }
  pos.eid = eid
  pos.cid = cid
  pos

describe "CompSet", ->
  target = null

  beforeEach ->
    target = new CompSet(5,10,"test comp set")

  it "constructs empty", ->
    expect(target.length).to.eql(5)
    expect(target.count).to.eql(0)

  describe "add()", ->
    it "adds a component", ->
      target.add(newPosition())
      target.add(newPosition())
      expect(target.length).to.eql(5)
      expect(target.count).to.eql(2)

    it "grows the internal storage as needed", ->
      for i in [0...5]
        target.add(newPosition())
      expect(target.length).to.eql(5)
      expect(target.count).to.eql(5)
      
      target.add(newPosition())
      expect(target.length).to.eql(15)
      expect(target.count).to.eql(6)

      for i in [0...9]
        target.add(newPosition())
      expect(target.length).to.eql(15)
      expect(target.count).to.eql(15)

      target.add(newPosition())
      expect(target.length).to.eql(25)
      expect(target.count).to.eql(16)

  describe "each()", ->
    captureEach = (t) ->
      res = []
      t.each (c) -> res.push(c)
      res

    it "retrieves the objects that have been added", ->
      expect(captureEach(target)).to.eql([])
      pos1 = newPosition(0,0,1,2)
      pos2 = newPosition(42,37,1,3)
      target.add(pos1)
      target.add(pos2)
      expect(captureEach(target)).to.eql([pos1,pos2])

    it "excludes deleted comps", ->
      pos1 = newPosition(0,0,1,2)
      pos2 = newPosition(42,37,1,3)
      pos3 = newPosition(44,55,1,4)
      target.add(pos1)
      target.add(pos2)
      target.add(pos3)
      target.deleteByCid(pos2.cid)
      expect(captureEach(target)).to.eql([pos1,pos3])
      target.deleteByCid(pos1.cid)
      expect(captureEach(target)).to.eql([pos3])
      target.deleteByCid(pos3.cid)
      expect(captureEach(target)).to.eql([])

    it "protects from concurrent modification (add)", ->
      pos1 = newPosition(0,0,99,1)
      pos2 = newPosition(42,37,99,2)
      pos3 = newPosition(44,55,99,3)
      target.add(pos1)
      target.add(pos2)
      target.add(pos3)

      pos4 = newPosition(401,402,99,4)
      pos5 = newPosition(501,502,99,5)
      adds = [pos4,pos5]

      res = []
      target.each (comp) ->
        res.push(comp)
        if adds.length > 0
          target.add adds.shift()

      # As we iterated, the newly added comps should not have been encountered
      expect(res).to.eql([pos1,pos2,pos3])

      # ...but this time they should be there:
      expect(captureEach(target)).to.eql([pos1,pos2,pos3,pos4,pos5])

    it "protects from concurrent modification (delete)", ->
      pos1 = newPosition(0,0,99,1)
      pos2 = newPosition(42,37,99,2)
      pos3 = newPosition(44,55,99,3)
      target.add(pos1)
      target.add(pos2)
      target.add(pos3)

      res = []
      target.each (comp) ->
        res.push(comp)
        target.deleteByCid(comp.cid)
        target.deleteByCid(comp.cid+1)

      # As we iterated, the deleted comps should still have been encountered
      expect(res).to.eql([pos1,pos2,pos3])

      # ...but this time they should be gone:
      expect(captureEach(target)).to.eql([])

    it "provides for early iteration exit via BreakEach", ->
      pos1 = newPosition(0,0,99,1)
      pos2 = newPosition(42,37,99,2)
      pos3 = newPosition(44,55,99,3)
      target.add(pos1)
      target.add(pos2)
      target.add(pos3)

      res = []
      target.each (comp) ->
        res.push(comp)
        if res.length >= 2
          return CompSet.BreakEach

      expect(res).to.eql([pos1,pos2])


  describe "single()", ->
    it "retrieves the singular object", ->
      expect(target.single()).to.eql(null)

      pos1 = newPosition(0,0,1,2)
      target.add(pos1)
      expect(target.single()).to.eql(pos1)

    it "(actually for now) retrieves the first of several", ->
      pos1 = newPosition(0,0,1,2)
      pos2 = newPosition(3,4,1,6)
      target.add(pos1)
      target.add(pos2)
      expect(target.single()).to.eql(pos1)
      target.deleteByCid(pos1.cid)
      expect(target.single()).to.eql(pos2)
      target.deleteByCid(pos2.cid)
      expect(target.single()).to.eql(null)

  describe "getByCid()", ->
    it "gets the component", ->
      pos1 = newPosition(0,0,1,2)
      pos2 = newPosition(3,4,1,6)
      pos3 = newPosition(3,4,1,7)
      target.add(pos1)
      target.add(pos2)
      target.add(pos3)
      expect(target.getByCid(2)).to.eql(pos1)
      expect(target.getByCid(6)).to.eql(pos2)

  describe "clone()", ->
    cloned = pos1 = pos2 = pos3 = pos1Bak = pos2Bak = pos3Bak = null
    beforeEach ->
      pos1 = newPosition(0,0,1,2)
      pos2 = newPosition(3,4,1,6)
      pos3 = newPosition(5,6,1,7)
      pos1Bak = pos1.clone()
      pos2Bak = pos2.clone()
      pos3Bak = pos3.clone()
      target.add(pos1)
      target.add(pos2)
      target.add(pos3)
      cloned = target.clone()
      expect(cloned).to.exist
      verifyTargetUnchanged()

    verifyTargetUnchanged = ->
      cs = []
      target.each (c) -> cs.push c
      expect(cs.length).to.equal(3,"target compset size changed")
      expect(cs[0]).to.eql(pos1Bak,"target comp[0] changed")
      expect(cs[1]).to.eql(pos2Bak,"target comp[1] changed")
      expect(cs[2]).to.eql(pos3Bak,"target comp[2] changed")

    it "makes another CompSet with the same contents", ->
      # console.log cloned
      ccs = []
      cloned.each (c) ->
        # console.log c
        ccs.push c
      expect(ccs[0].equals(pos1)).to.be.true
      expect(ccs[1].equals(pos2)).to.be.true
      expect(ccs[2].equals(pos3)).to.be.true
      expect(cloned.name).to.equal(target.name)
      expect(cloned.length).to.equal(target.length)
      expect(cloned.count).to.equal(target.count)
      expect(cloned.ect).to.equal(target.ect)

    it "doesn't affect the original compset when adding", ->
      pos4 = newPosition(101,202,2,3)
      cloned.add(pos4)
      verifyTargetUnchanged()

    it "doesn't affect the original comps when cloned comps are modified", ->
      p = cloned.getByCid(6) # pos2
      p.x = 555
      p.y = 666
      verifyTargetUnchanged()
      pAgain = cloned.getByCid(6)
      expect(pAgain.x).to.equal(555)
      expect(pAgain.y).to.equal(666)

    it 'works on compsets that have grown and have internal gaps', ->
      pos4 = newPosition(44,400)
      pos5 = newPosition(55,500)
      pos6 = newPosition(66,666)
      target.add(pos4)
      target.add(pos5)
      target.add(pos6) # forces grow since target started w 5 slots
      target.deleteByCid(pos2.cid) # make an internal gap
      target.deleteByCid(pos3.cid) # make another internal gap

      cloned = target.clone()

      ccs = []
      cloned.each (c) ->
        ccs.push c

      expect(ccs[0].equals(pos1)).to.be.true
      expect(ccs[1].equals(pos4)).to.be.true
      expect(ccs[2].equals(pos5)).to.be.true
      expect(ccs[3].equals(pos6)).to.be.true
      expect(cloned.length).to.equal(5,"cloned shouldn't have internally grown")
      expect(cloned.count).to.equal(4)









