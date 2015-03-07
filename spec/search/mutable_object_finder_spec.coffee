Finder = require '../../src/javascript/search/mutable_object_finder'

Immutable = require 'immutable'

chai = require('chai')
expect = chai.expect
assert = chai.assert

imm = Immutable.fromJS

# expectArray = (actual,expected) ->
#   if !Immutable.is(actual,expected)
#     assert.fail(actual,expected,"Immutable structures not equal.\nExpected: #{expected.toString()}\n  Actual: #{actual.toString()}")

expectArray = (got,expected) ->
  expect(got.length).to.eq expected.length
  expect(got).to.deep.include.members(expected)

zeldaObjects = [
  { eid: 'e1', type: 'tag', value: 'hero' }
  { eid: 'e1', type: 'character', name: 'Link' }
  { eid: 'e1', type: 'bbox', shape: [1,2,3,4] }
  { eid: 'e1', type: 'inventory', stuff: 'items' }

  { eid: 'e1', type: 'tag', value: 'enemy' }
  { eid: 'e2', type: 'character', name: 'Tektike' }
  { eid: 'e2', type: 'bbox', shape: [3,4,5,6] }
  { eid: 'e2', type: 'digger', status: 'burrowing' }
]

searchZelda = (filters) -> Finder.search zeldaObjects, imm(filters)

typeFilter = (t) -> { match: { type: t } }

describe 'MutableObjectFinder.search', ->

  it 'can match on a single criteria', ->
    charFilter =
      match: { type: 'character' }
      as: 'char'

    expectArray searchZelda([charFilter]), [
      { char: zeldaObjects[1] }
      { char: zeldaObjects[5] }
    ]
    
  it 'can match on multiple criteria', ->
    linkFilter =
      match: { type: 'character', name: 'Link' }
      as: 'linkChar'

    expectArray searchZelda([linkFilter]), [
      { linkChar: zeldaObjects[1] }
    ]
  
  describe 'when filters omit "as"', ->
    it 'labels results based on first matcher value', ->
      filter = imm
        match:
          name: 'Tektike'

      expectArray searchZelda([filter]), [
        { "Tektike": zeldaObjects[5] }
      ]

      filter2 = imm
        match:
          type: 'digger'

      expectArray searchZelda([filter2]), [
        { digger: zeldaObjects[7] }
      ]

  
  describe 'with multiple filters', ->
    it 'permutes the combinations of objects', ->
      cf = typeFilter 'character'
      bf = typeFilter 'bbox'
      expectArray searchZelda([cf,bf]), [
        { character: zeldaObjects[1], bbox: zeldaObjects[2] }
        { character: zeldaObjects[1], bbox: zeldaObjects[6] }
        { character: zeldaObjects[5], bbox: zeldaObjects[2] }
        { character: zeldaObjects[5], bbox: zeldaObjects[6] }
      ]
  
  describe 'with joins', ->
    charFilter =
      match: { type: 'character' }

    boxFilter =
      match: { type: 'bbox' }
      join: 'character.eid'

    heroTagFilter =
      match:
        type: 'tag'
        value: 'hero'
      join: 'character.eid'

    it 'constrains results by matching joined attributes', ->
      expectArray searchZelda([charFilter, boxFilter]), [
        { character: zeldaObjects[1], bbox: zeldaObjects[2] }
        { character: zeldaObjects[5], bbox: zeldaObjects[6] }
      ]

    it 'joins and filters on multiple components', ->
      filters = [
        charFilter
        boxFilter
        heroTagFilter
      ]
      expectArray searchZelda(filters), [
        { character: zeldaObjects[1], bbox: zeldaObjects[2], tag: zeldaObjects[0] }
      ]

    it 'does nothing with superfluous joins', ->
      f =
        match: { type: 'character' }
        join: 'super.fluous'

      expectArray searchZelda([f]), [
        { character: zeldaObjects[1] }
        { character: zeldaObjects[5] }
      ]
