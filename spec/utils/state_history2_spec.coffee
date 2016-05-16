Immutable = require 'immutable'
imm = Immutable.fromJS
{Map,List} = Immutable

chai = require('chai')
expect = chai.expect
assert = chai.assert
expectIs = require('../helpers/expect_helpers').expectIs

RollingHistory = require '../../src/javascript/utils/rolling_history'

# addAll = (buf,xs) ->
#   for x in xs
#     buf = B.add(buf,x)
#   buf

describe "RollingHistory2", ->
  describe "empty", ->
    it "is empty", ->
      expectIs RollingHistory.empty, imm(data:[],maxSize:300,index:0)

  describe "adding items", ->
    it "can add and read items", ->
      h = RollingHistory.empty
      expect(RollingHistory.size(h)).to.equal(0)

      h = RollingHistory.add(h, "wonder")
      expect(RollingHistory.current(h)).to.equal("wonder")
      expect(RollingHistory.size(h)).to.equal(1)
      expectIs h, imm(data:["wonder"],maxSize:300,index:0)

      h = RollingHistory.add(h, "what's")
      h = RollingHistory.add(h, "dinner")
      expect(RollingHistory.size(h)).to.equal(3)
      expect(RollingHistory.current(h)).to.equal("dinner")
      expectIs h, imm(data:["wonder","what's","dinner"],maxSize:300,index:2)

    describe "past maxSize", ->
      it "drops members off the front", ->
        h = RollingHistory.empty.set('maxSize',3)
        h = RollingHistory.add(h, "one")
        h = RollingHistory.add(h, "two")
        h = RollingHistory.add(h, "three")
        expect(RollingHistory.current(h)).to.equal("three")
        expect(RollingHistory.size(h)).to.equal(3)
        expectIs h, imm(data:["one","two","three"],maxSize:3,index:2)

        h = RollingHistory.add(h, "four")
        expect(RollingHistory.current(h)).to.equal("four")
        expect(RollingHistory.size(h)).to.equal(3)
        expectIs h, imm(data:["two","three","four"],maxSize:3,index:2)

        h = RollingHistory.add(h, "five")
        expect(RollingHistory.current(h)).to.equal("five")
        expect(RollingHistory.size(h)).to.equal(3)
        expectIs h, imm(data:["three","four","five"],maxSize:3,index:2)

  describe "movement and truncation", ->
    h = RollingHistory.empty
    h = RollingHistory.add(h, "bird")
    h = RollingHistory.add(h, "black")
    h = RollingHistory.add(h, "wing")
    h = RollingHistory.add(h, "red")

    it "can index forward and backward", ->
      expect(RollingHistory.current(h)).to.equal("red")
      h = RollingHistory.back(h)
      expect(RollingHistory.current(h)).to.equal("wing")
      h = RollingHistory.back(h)
      expect(RollingHistory.current(h)).to.equal("black")
      h = RollingHistory.back(h)
      expect(RollingHistory.current(h)).to.equal("bird")

      h = RollingHistory.back(h)
      h = RollingHistory.back(h)
      expect(RollingHistory.current(h)).to.equal("bird")

      h = RollingHistory.forward(h)
      expect(RollingHistory.current(h)).to.equal("black")
      h = RollingHistory.forward(h)
      expect(RollingHistory.current(h)).to.equal("wing")
      h = RollingHistory.forward(h)
      expect(RollingHistory.current(h)).to.equal("red")
      h = RollingHistory.forward(h)
      h = RollingHistory.forward(h)
      expect(RollingHistory.current(h)).to.equal("red")

    it "can index directly to beginning and end", ->
      expect(RollingHistory.current(h)).to.equal("red")
      h = RollingHistory.indexToStart(h)
      expect(RollingHistory.current(h)).to.equal("bird")
      h = RollingHistory.indexToStart(h)
      expect(RollingHistory.current(h)).to.equal("bird")

      h = RollingHistory.indexToEnd(h)
      expect(RollingHistory.current(h)).to.equal("red")
      h = RollingHistory.indexToEnd(h)
      expect(RollingHistory.current(h)).to.equal("red")

    it "can drop all data after the current value", ->
      h = RollingHistory.indexToStart(h)
      h = RollingHistory.forward(h)
      expect(RollingHistory.current(h)).to.equal("black")
      h = RollingHistory.truncate(h)
      expect(RollingHistory.current(h)).to.equal("black")
      expectIs h, imm(data:["bird","black"],maxSize:300,index:1)
      

