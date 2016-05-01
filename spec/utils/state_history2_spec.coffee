Immutable = require 'immutable'
imm = Immutable.fromJS
{Map,List} = Immutable

chai = require('chai')
expect = chai.expect
assert = chai.assert
expectIs = require('../helpers/expect_helpers').expectIs

StateHistory = require '../../src/javascript/utils/state_history2'

# addAll = (buf,xs) ->
#   for x in xs
#     buf = B.add(buf,x)
#   buf

describe "StateHistory2", ->
  describe "empty", ->
    it "is empty", ->
      expectIs StateHistory.empty, imm(data:[],maxSize:300,index:0)

  describe "adding items", ->
    it "can add and read items", ->
      h = StateHistory.empty
      expect(StateHistory.size(h)).to.equal(0)

      h = StateHistory.add(h, "wonder")
      expect(StateHistory.current(h)).to.equal("wonder")
      expect(StateHistory.size(h)).to.equal(1)
      expectIs h, imm(data:["wonder"],maxSize:300,index:0)

      h = StateHistory.add(h, "what's")
      h = StateHistory.add(h, "dinner")
      expect(StateHistory.size(h)).to.equal(3)
      expect(StateHistory.current(h)).to.equal("dinner")
      expectIs h, imm(data:["wonder","what's","dinner"],maxSize:300,index:2)

    describe "past maxSize", ->
      it "drops members off the front", ->
        h = StateHistory.empty.set('maxSize',3)
        h = StateHistory.add(h, "one")
        h = StateHistory.add(h, "two")
        h = StateHistory.add(h, "three")
        expect(StateHistory.current(h)).to.equal("three")
        expect(StateHistory.size(h)).to.equal(3)
        expectIs h, imm(data:["one","two","three"],maxSize:3,index:2)

        h = StateHistory.add(h, "four")
        expect(StateHistory.current(h)).to.equal("four")
        expect(StateHistory.size(h)).to.equal(3)
        expectIs h, imm(data:["two","three","four"],maxSize:3,index:2)

        h = StateHistory.add(h, "five")
        expect(StateHistory.current(h)).to.equal("five")
        expect(StateHistory.size(h)).to.equal(3)
        expectIs h, imm(data:["three","four","five"],maxSize:3,index:2)

  describe "movement and truncation", ->
    h = StateHistory.empty
    h = StateHistory.add(h, "bird")
    h = StateHistory.add(h, "black")
    h = StateHistory.add(h, "wing")
    h = StateHistory.add(h, "red")

    it "can index forward and backward", ->
      expect(StateHistory.current(h)).to.equal("red")
      h = StateHistory.back(h)
      expect(StateHistory.current(h)).to.equal("wing")
      h = StateHistory.back(h)
      expect(StateHistory.current(h)).to.equal("black")
      h = StateHistory.back(h)
      expect(StateHistory.current(h)).to.equal("bird")

      h = StateHistory.back(h)
      h = StateHistory.back(h)
      expect(StateHistory.current(h)).to.equal("bird")

      h = StateHistory.forward(h)
      expect(StateHistory.current(h)).to.equal("black")
      h = StateHistory.forward(h)
      expect(StateHistory.current(h)).to.equal("wing")
      h = StateHistory.forward(h)
      expect(StateHistory.current(h)).to.equal("red")
      h = StateHistory.forward(h)
      h = StateHistory.forward(h)
      expect(StateHistory.current(h)).to.equal("red")

    it "can index directly to beginning and end", ->
      expect(StateHistory.current(h)).to.equal("red")
      h = StateHistory.indexToStart(h)
      expect(StateHistory.current(h)).to.equal("bird")
      h = StateHistory.indexToStart(h)
      expect(StateHistory.current(h)).to.equal("bird")

      h = StateHistory.indexToEnd(h)
      expect(StateHistory.current(h)).to.equal("red")
      h = StateHistory.indexToEnd(h)
      expect(StateHistory.current(h)).to.equal("red")

    it "can drop all data after the current value", ->
      h = StateHistory.indexToStart(h)
      h = StateHistory.forward(h)
      expect(StateHistory.current(h)).to.equal("black")
      h = StateHistory.truncate(h)
      expect(StateHistory.current(h)).to.equal("black")
      expectIs h, imm(data:["bird","black"],maxSize:300,index:1)
      

