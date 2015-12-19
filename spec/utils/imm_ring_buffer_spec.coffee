Immutable = require 'immutable'
imm = Immutable.fromJS

chai = require('chai')
expect = chai.expect
assert = chai.assert
expectIs = require('../helpers/expect_helpers').expectIs

ImmRingBuffer = require '../../src/javascript/utils/imm_ring_buffer'
B = ImmRingBuffer

addAll = (buf,xs) ->
  for x in xs
    buf = B.add(buf,x)
  buf

describe "ImmRingBuffer", ->
  describe "create, add and read", ->
    it "can add and read items from a buffer", ->
      buf = B.create(4)
      expect(B.read(buf)).to.equal(null)
      expect(B.isEmpty(buf)).to.equal(true)

      buf1 = B.add(buf, "one")
      expect(B.read(buf1)).to.equal("one")
      expect(B.isEmpty(buf1)).to.equal(false)

      buf2 = B.add(buf1, "two")
      expect(B.read(buf2)).to.equal("two")

      # see original vals haven't been mutated
      expect(B.read(buf)).to.equal(null)
      expect(B.read(buf1)).to.equal("one")
      expect(B.read(buf2)).to.equal("two")

    it "starts writing over oldest data when maxSize is surpassed", ->
      buf = addAll(B.create(4), ["one","two","three","four"])
      expect(B.read(buf)).to.equal("four")
      expectIs B.sneakAPeek(buf), imm(["one","two","three","four"])

      buf = B.add(buf, "five")
      expect(B.read(buf)).to.equal("five")
      expectIs B.sneakAPeek(buf), imm(["five","two","three","four"])
      buf = B.add(buf, "six")
      expect(B.read(buf)).to.equal("six")
      expectIs B.sneakAPeek(buf), imm(["five","six","three","four"])

  describe "forward and backward", ->
    it "moves the read pointer back and forth over the data", ->
      buf = addAll(B.create(4), ["one","two","three","four","five","six"])
      expectIs B.sneakAPeek(buf), imm(["five","six","three","four"])

      expect(B.read(buf)).to.equal("six")
      expect(B.isAtHead(buf)).to.equal(true)
      expect(B.isAtTail(buf)).to.equal(false)

      buf = B.backward(buf)
      expect(B.read(buf)).to.equal("five")
      expect(B.isAtHead(buf)).to.equal(false)
      expect(B.isAtTail(buf)).to.equal(false)

      buf = B.backward(buf)
      expect(B.read(buf)).to.equal("four")
      expect(B.isAtHead(buf)).to.equal(false)
      expect(B.isAtTail(buf)).to.equal(false)

      buf = B.backward(buf)
      expect(B.read(buf)).to.equal("three")
      # See we're at the tail:
      expect(B.isAtTail(buf)).to.equal(true)
      expect(B.isAtHead(buf)).to.equal(false)

      # See we can't go further back:
      buf = B.backward(buf)
      expect(B.isAtTail(buf)).to.equal(true)
      expect(B.read(buf)).to.equal("three")

      # Walk forward again:
      buf = B.forward(buf)
      expect(B.read(buf)).to.equal("four")
      expect(B.isAtTail(buf)).to.equal(false)
      expect(B.isAtHead(buf)).to.equal(false)

      buf = B.forward(buf)
      expect(B.read(buf)).to.equal("five")
      expect(B.isAtTail(buf)).to.equal(false)
      expect(B.isAtHead(buf)).to.equal(false)

      buf = B.forward(buf)
      expect(B.read(buf)).to.equal("six")
      expect(B.isAtTail(buf)).to.equal(false)
      # See we've returned to the head:
      expect(B.isAtHead(buf)).to.equal(true)

      # See we cannot fo further:
      buf = B.forward(buf)
      expect(B.read(buf)).to.equal("six")
      expect(B.isAtTail(buf)).to.equal(false)
      expect(B.isAtHead(buf)).to.equal(true)

  describe "clear", ->
    it "removes the data", ->
      buf = B.create(4)
      buf1 = addAll(buf, ["one","two","three","four"])
      expectIs B.sneakAPeek(buf1), imm(["one","two","three","four"])

      buf2 = B.clear(buf1)
      expectIs buf2, buf
      expectIs B.sneakAPeek(buf2), imm([null,null,null,null])
      
  describe "truncate", ->
    it "moves the head of the ring to the current read position, dropping any following data", ->
      buf = addAll(B.create(4), ["one","two","three","four","five","six"])
      buf = B.backward(buf)
      buf = B.backward(buf)
      expect(B.read(buf)).to.equal("four")
      expect(B.isAtTail(buf)).to.equal(false)
      expect(B.isAtHead(buf)).to.equal(false)
      expectIs B.sneakAPeek(buf), imm(["five","six","three","four"])

      buf = B.truncate(buf)
      expect(B.read(buf)).to.equal("four")
      expect(B.isAtTail(buf)).to.equal(false)
      expect(B.isAtHead(buf)).to.equal(true)

      # See we can't move forward
      buf = B.forward(buf)
      expect(B.read(buf)).to.equal("four")
      expect(B.isAtTail(buf)).to.equal(false)
      expect(B.isAtHead(buf)).to.equal(true)

      # See we can move back just once from here
      buf = B.backward(buf)
      expect(B.read(buf)).to.equal("three")
      expect(B.isAtTail(buf)).to.equal(true)
      expect(B.isAtHead(buf)).to.equal(false)
      buf = B.backward(buf)
      expect(B.read(buf)).to.equal("three")

  describe "An empty buffer", ->
    buf = B.create(4)

    it "returns true for isEmpty", ->
      expect(B.isEmpty(buf)).to.equal(true)

    it "reads null", ->
      expect(B.read(buf)).to.equal(null)

    it "silently refuses modification ops", ->
      buf1 = B.forward(buf)
      expectIs buf1, buf
      buf1 = B.backward(buf)
      expectIs buf1, buf
      buf1 = B.truncate(buf)
      expectIs buf1, buf
      buf1 = B.clear(buf)
      expectIs buf1, buf # of course, this is just proper clear() behavior


    it "is both at the head and tail", ->
      expect(B.isAtHead(buf)).to.equal(true)
      expect(B.isAtTail(buf)).to.equal(true)

  describe "An empty 1-length buffer", ->
    buf = B.create(1)

    it "returns true for isEmpty", ->
      expect(B.isEmpty(buf)).to.equal(true)

    it "reads null", ->
      expect(B.read(buf)).to.equal(null)

    it "silently refuses modification ops", ->
      buf1 = B.forward(buf)
      expectIs buf1, buf
      buf1 = B.backward(buf)
      expectIs buf1, buf
      buf1 = B.truncate(buf)
      expectIs buf1, buf
      buf1 = B.clear(buf)
      expectIs buf1, buf # of course, this is just proper clear() behavior

    it "is both at the head and tail", ->
      expect(B.isAtHead(buf)).to.equal(true)
      expect(B.isAtTail(buf)).to.equal(true)
    
  describe "A 1-length buffer with data", ->
    buf = B.add(B.create(1), "hello")

    it "can read", ->
      expect(B.isEmpty(buf)).to.equal(false)
      expect(B.read(buf)).to.equal("hello")

    it "is both at the head and tail", ->
      expect(B.isAtHead(buf)).to.equal(true)
      expect(B.isAtTail(buf)).to.equal(true)

    it "truncation and motion are no-ops", ->
      buf1 = B.forward(buf)
      expect(B.read(buf1)).to.equal("hello")
      expect(B.isAtHead(buf1)).to.equal(true)
      expect(B.isAtTail(buf1)).to.equal(true)

      buf1 = B.backward(buf)
      expect(B.read(buf1)).to.equal("hello")
      expect(B.isAtHead(buf1)).to.equal(true)
      expect(B.isAtTail(buf1)).to.equal(true)

      buf1 = B.truncate(buf)
      expect(B.read(buf1)).to.equal("hello")
      expect(B.isAtHead(buf1)).to.equal(true)
      expect(B.isAtTail(buf1)).to.equal(true)

    it "writes in place", ->
      buf1 = B.add(buf,"world")
      expect(B.read(buf1)).to.equal("world")

      buf2 = B.add(B.add(B.add(buf1,"welcome"), "to"), "zombo.com")
      expect(B.read(buf2)).to.equal("zombo.com")



    



