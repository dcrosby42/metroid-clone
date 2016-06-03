chai = require('chai')
expect = chai.expect
assert = chai.assert

CompSet = require '../../src/javascript/ecs2/comp_set'
C = require '../../src/javascript/components'
{Position} = C
describe "CompSet", ->
  target = null

  beforeEach ->
    target = new CompSet(5,10)

  it "constructs empty", ->
    expect(target.length).to.eql(5)
    expect(target.count).to.eql(0)

  describe "add()", ->
    it "adds a component", ->
      target.add(new Position())
      target.add(new Position())
      expect(target.length).to.eql(5)
      expect(target.count).to.eql(2)

    it "grows the internal storage as needed", ->
      for i in [0...5]
        target.add(new Position())
      expect(target.length).to.eql(5)
      expect(target.count).to.eql(5)
      
      target.add(new Position())
      expect(target.length).to.eql(15)
      expect(target.count).to.eql(6)

      for i in [0...9]
        target.add(new Position())
      expect(target.length).to.eql(15)
      expect(target.count).to.eql(15)

      target.add(new Position())
      expect(target.length).to.eql(25)
      expect(target.count).to.eql(16)

  describe "each()", ->
    captureEach = (t) ->
      res = []
      t.each (c) -> res.push(c)
      res

    it "retrieves the objects that have been added", ->
      expect(captureEach(target)).to.eql([])
      pos1 = new Position(0,0,1,2)
      pos2 = new Position(42,37,1,3)
      target.add(pos1)
      target.add(pos2)
      expect(captureEach(target)).to.eql([pos1,pos2])

    it "excludes deleted comps", ->
      pos1 = new Position(0,0,1,2)
      pos2 = new Position(42,37,1,3)
      pos3 = new Position(44,55,1,4)
      target.add(pos1)
      target.add(pos2)
      target.add(pos3)
      target.deleteByCid(pos2.cid)
      expect(captureEach(target)).to.eql([pos1,pos3])
      target.deleteByCid(pos1.cid)
      expect(captureEach(target)).to.eql([pos3])
      target.deleteByCid(pos3.cid)
      expect(captureEach(target)).to.eql([])

  describe "single()", ->
    it "retrieves the singular object", ->
      expect(target.single()).to.eql(null)

      pos1 = new Position(0,0,1,2)
      target.add(pos1)
      expect(target.single()).to.eql(pos1)

    it "(actually for now) retrieves the first of several", ->
      pos1 = new Position(0,0,1,2)
      pos2 = new Position(3,4,1,6)
      target.add(pos1)
      target.add(pos2)
      expect(target.single()).to.eql(pos1)
      target.deleteByCid(pos1.cid)
      expect(target.single()).to.eql(pos2)
      target.deleteByCid(pos2.cid)
      expect(target.single()).to.eql(null)




