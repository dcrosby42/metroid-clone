
chai = require('chai')
expect = chai.expect
assert = chai.assert
expectIs = require('../helpers/expect_helpers').expectIs

RollingBuffer = require '../../src/javascript/utils/rolling_buffer'


describe "RollingBuffer", ->
  it "can be built", ->
    rf = new RollingBuffer()
    expect(rf).to.exist
    expect(rf.maxSize).to.equal(5*60)
    expect(rf.size).to.equal(0)

  describe "when empty", ->
    it "doesn't freak out", ->
      rf = new RollingBuffer(5)
      expect(rf.size).to.equal(0)
      expect(rf.current()).to.equal(null)
      rf.back()
      expect(rf.current()).to.equal(null)
      rf.forward()
      expect(rf.current()).to.equal(null)
      rf.offsetTo(100)
      expect(rf.current()).to.equal(null)
      rf.truncate()
      expect(rf.size).to.equal(0)
      expect(rf.current()).to.equal(null)
  describe "with 1 element", ->
    it "doesn't freak out", ->
      rf = new RollingBuffer(5)
      rf.add("thing")
      expect(rf.size).to.equal(1)
      expect(rf.current()).to.equal("thing")
      rf.back()
      expect(rf.current()).to.equal("thing")
      rf.forward()
      expect(rf.current()).to.equal("thing")
      rf.offsetTo(100)
      expect(rf.current()).to.equal("thing")
      rf.truncate()
      expect(rf.size).to.equal(1)
      expect(rf.current()).to.equal("thing")

  describe "add() and current()", ->
    it "can add and peek at items", ->
      rf = new RollingBuffer(5)
      rf.add("Blackened")
      expect(rf.size).to.equal(1)
      expect(rf.current()).to.equal("Blackened")

      rf.add("...And Justice For All")
      expect(rf.size).to.equal(2)
      expect(rf.current()).to.equal("...And Justice For All")

      # for n in [0...20]
      #   rf.add("lol")
      # expect(rf.size).to.equal(22)
      # expect(rf.current()).to.equal("lol")
        
  describe "offsetTo()", ->
    it "changes result of current()", ->
      rf = new RollingBuffer()
      rf.add("zero")
      rf.add("one")
      rf.add("two")
      rf.add("three")
      expect(rf.current()).to.equal("three")

      rf.offsetTo(2)
      expect(rf.current()).to.equal("two")

      rf.offsetTo(0)
      expect(rf.current()).to.equal("zero")

      rf.offsetTo(1)
      expect(rf.current()).to.equal("one")

      rf.offsetTo(3)
      expect(rf.current()).to.equal("three")

      rf.offsetTo(0)
      rf.add("four")
      expect(rf.current()).to.equal("four")


    it "enforces bonds if index out of range", ->
      rf = new RollingBuffer()
      rf.add("zero")
      rf.add("one")
      rf.add("two")
      rf.add("three")

      rf.offsetTo(-1)
      expect(rf.current()).to.equal("zero")
      rf.offsetTo(4)
      expect(rf.current()).to.equal("three")
      rf.offsetTo(1000)
      expect(rf.current()).to.equal("three")


  describe "back()", ->
    it "changes result of current() by indexing backward", ->
      rf = new RollingBuffer()
      rf.add("zero")
      rf.add("one")
      rf.add("two")

      rf.back()
      expect(rf.current()).to.equal("one")

      rf.back()
      expect(rf.current()).to.equal("zero")

      rf.back()
      rf.back()
      expect(rf.current()).to.equal("zero")

  describe "forward()", ->
    it "changes result of current() by indexing forward", ->
      rf = new RollingBuffer()
      rf.add("zero")
      rf.add("one")
      rf.add("two")

      rf.offsetTo(0)
      expect(rf.current()).to.equal("zero")

      rf.forward()
      expect(rf.current()).to.equal("one")

      rf.forward()
      rf.forward()
      expect(rf.current()).to.equal("two")

  describe "rolling'", ->
    it "drops oldest values to make room for new", ->
      rf = new RollingBuffer(3)
      rf.add("zero")
      rf.add("one")
      rf.add("two")
      # Sanity check
      expect(rf.current()).to.equal("two")
      rf.offsetTo(0)
      expect(rf.current()).to.equal("zero")
      rf.offsetTo(2)
      expect(rf.current()).to.equal("two")
      expect(rf.size).to.equal(3)

      # Rollover 1
      rf.add("three")
      expect(rf.current()).to.equal("three")
      expect(rf.size).to.equal(3)
      rf.back()
      expect(rf.current()).to.equal("two")
      rf.back()
      expect(rf.current()).to.equal("one")
      rf.back()
      rf.back()
      expect(rf.current()).to.equal("one")


      rf.add("four")
      rf.add("five")
      expect(rf.current()).to.equal("five")
      expect(rf.size).to.equal(3)
      rf.back()
      expect(rf.current()).to.equal("four")
      rf.back()
      expect(rf.current()).to.equal("three")
      rf.back()
      rf.back()
      expect(rf.current()).to.equal("three")

      # trigger a second rollover
      rf.add("six")
      expect(rf.size).to.equal(3)
      expect(rf.current()).to.equal("six")
      rf.back()
      expect(rf.current()).to.equal("five")
      rf.back()
      expect(rf.current()).to.equal("four")
      rf.back()
      rf.back()
      expect(rf.current()).to.equal("four")

      rf.offsetTo(0)
      expect(rf.current()).to.equal("four")
      rf.offsetTo(1)
      expect(rf.current()).to.equal("five")
      rf.offsetTo(2)
      expect(rf.current()).to.equal("six")

    it "can do 900", ->
      rf = new RollingBuffer(300)
      for i in [0...900]
        rf.add("item-#{i}")
      expect(rf.size).to.equal(300)
      expect(rf.current()).to.equal("item-899")
      rf.offsetTo(0)
      expect(rf.current()).to.equal("item-600")
      
  describe "truncate()", ->
    it "removes all values beyond the current offset", ->
      rf = new RollingBuffer(5)
      rf.add("zero")
      rf.add("one")
      rf.add("two")
      rf.add("three")
      rf.add("four")
      rf.offsetTo(2)
      expect(rf.size).to.equal(5)
      expect(rf.current()).to.equal("two")

      rf.truncate()
      expect(rf.size).to.equal(3)
      expect(rf.current()).to.equal("two")
      rf.forward()
      rf.forward()
      expect(rf.current()).to.equal("two")

    it "handles rollover good", ->
      rf = new RollingBuffer(3)
      rf.add("zero")
      rf.add("one")
      rf.add("two")
      rf.add("three")
      rf.add("four")
      # [ three four two ]
      expect(rf.size).to.equal(3)
      rf.offsetTo(1)
      expect(rf.current()).to.equal("three")

      rf.truncate()
      expect(rf.size).to.equal(2)
      expect(rf.current()).to.equal("three")
      rf.forward()
      expect(rf.current()).to.equal("three")
      rf.back()
      expect(rf.current()).to.equal("two")
      






  # describe "remove()", ->

