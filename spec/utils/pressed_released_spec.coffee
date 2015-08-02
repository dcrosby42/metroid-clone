Immutable = require 'immutable'
imm = Immutable.fromJS

chai = require('chai')
expect = chai.expect
assert = chai.assert
expectIs = require('../helpers/expect_helpers').expectIs

PressedReleased = require '../../src/javascript/utils/pressed_released'

describe "PressedReleased.update", ->
  it "sets xPressed on first false->true", ->
    s = imm(left: false)
    input = imm(left: true)
    s1 = PressedReleased.update(s, input)
    expectIs s1, imm
      left: true
      leftPressed: true

    s2 = PressedReleased.update(s1, input)
    expectIs s2, imm(left: true)

  it "sets xReleased on first true->false", ->
    s = imm(right: true)
    input = imm(right: false)
    s1 = PressedReleased.update(s, input)
    expectIs s1, imm
      right: false
      rightReleased: true

    s2 = PressedReleased.update(s1, input)
    expectIs s2, imm(right: false)
    
  it "removes *Released and *Pressed keys if inputs not mentioned", ->
    s = imm
      sheep: true
      sheepPressed: true
      ram: false
      ramReleased: true

    input = imm(goat: true)

    s1 = PressedReleased.update(s, input)
    expectIs s1, imm
      sheep: true
      ram: false
      goat: true
      goatPressed: true

  it "can handle multiple vars and transitions simultaneously", ->
    s = imm
      ant: false
      dog: true
      kat: true

    input = imm
      ant: true
      dog: false

    s1 = PressedReleased.update(s, input)
    expectIs s1, imm
      ant: true
      antPressed: true
      dog: false
      dogReleased: true
      kat: true

  it "doesn't wholly rely on pre-existing values in state map", ->
    s = imm({})

    s1 = PressedReleased.update(s, imm(a:true))
    expectIs s1, imm(a:true, aPressed:true)
    
    s2 = PressedReleased.update(s1, imm(b:true))
    expectIs s2, imm(a:true, b:true, bPressed:true)

    s3 = PressedReleased.update(s2, imm({}))
    expectIs s3, imm(a:true, b:true)

    s4 = PressedReleased.update(s3, imm({a:false}))
    expectIs s4, imm(a:false, aReleased:true, b:true)

    s5 = PressedReleased.update(s4, imm({b:false}))
    expectIs s5, imm(a:false, b:false, bReleased: true)
    

    
