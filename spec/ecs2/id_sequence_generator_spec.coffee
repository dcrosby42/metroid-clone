_ = require 'lodash'
Immutable = require 'immutable'

chai = require('chai')
expect = chai.expect
assert = chai.assert

imm = Immutable.fromJS
expectIs = require('../helpers/expect_helpers').expectIs

IdSequenceGenerator = require '../../src/javascript/ecs/id_sequence_generator'

describe '.new', ->
  it "initializes the expected generator structure with default prefix and number", ->
    gen = IdSequenceGenerator.new()
    expectIs gen, imm
      number: 0
      prefix: 'id'
      value: 'id0'
      
  it "initializes the expected generator structure with given prefix and default number", ->
    gen = IdSequenceGenerator.new('the-')
    expectIs gen, imm
      number: 0
      prefix: 'the-'
      value: 'the-0'

  it "initializes the expected generator structure with given prefix and number", ->
    gen = IdSequenceGenerator.new('x',42)
    expectIs gen, imm
      number: 42
      prefix: 'x'
      value: 'x42'

describe '.next', ->
  gen = IdSequenceGenerator.new('r',5)
    
  it "increments the number and value", ->
    gen1 = IdSequenceGenerator.next(gen)
    expectIs gen1, imm
      number: 6
      prefix: 'r'
      value: 'r6'

    gen2 = IdSequenceGenerator.next(gen1)
    expectIs gen2, imm
      number: 7
      prefix: 'r'
      value: 'r7'
      
  it "does not mutate its input", ->
    gen1 = IdSequenceGenerator.next(gen)
    expectIs gen1, imm
      number: 6
      prefix: 'r'
      value: 'r6'

    expectIs gen, imm
      number: 5
      prefix: 'r'
      value: 'r5'
