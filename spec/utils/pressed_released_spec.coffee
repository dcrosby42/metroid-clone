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
