Finder = require '../../src/javascript/search/immutable_object_finder'
Immutable = require 'immutable'
ExpectHelpers = require '../helpers/expect_helpers'
expectIs = ExpectHelpers.expectIs

chai = require('chai')
expect = chai.expect
assert = chai.assert

imm = Immutable.fromJS


zeldaObjects = Immutable.fromJS [
  { eid: 'e1', type: 'tag', value: 'hero' }
  { eid: 'e1', type: 'character', name: 'Link' }
  { eid: 'e1', type: 'bbox', shape: [1,2,3,4] }
  { eid: 'e1', type: 'inventory', stuff: 'items' }

  { eid: 'e1', type: 'tag', value: 'enemy' }
  { eid: 'e2', type: 'character', name: 'Tektike' }
  { eid: 'e2', type: 'bbox', shape: [3,4,5,6] }
  { eid: 'e2', type: 'digger', status: 'burrowing' }

  { eid: 'e1', type: 'hat', color: 'green' }
  { eid: 'e99', extraneous: 'hat', type: 'other-thing', sha: 'zam' }
]

searchZelda = (filters) -> Finder.search zeldaObjects, imm(filters)

typeFilter = (t) -> imm { match: { type: t } }


describe 'ImmutableObjectFinder.search', ->

  it 'can match on a single criteria', ->
    charFilter = imm
      match: { type: 'character' }
      as: 'char'

    expectIs searchZelda([charFilter]), imm([
      { char: zeldaObjects.get(1) }
      { char: zeldaObjects.get(5) }
    ])
    
  it 'can match on multiple criteria', ->
    linkFilter = imm
      match: { type: 'character', name: 'Link' }
      as: 'linkChar'

    expectIs searchZelda([linkFilter]), imm([
      { linkChar: zeldaObjects.get(1) }
    ])

  describe 'when filters omit "as"', ->
    it 'labels results based on first matcher value', ->
      filter = imm
        match:
          name: 'Tektike'
      expectIs searchZelda([filter]), imm([
        { "Tektike": zeldaObjects.get(5) }
      ])

      filter2 = imm
        match:
          type: 'digger'
      expectIs searchZelda([filter2]), imm [
        { digger: zeldaObjects.get(7) }
      ]

  describe 'with multiple filters', ->
    it 'permutes the combinations of objects', ->
      cf = typeFilter 'character'
      bf = typeFilter 'bbox'
      expectIs searchZelda([cf,bf]), imm [
        { character: zeldaObjects.get(1), bbox: zeldaObjects.get(2) }
        { character: zeldaObjects.get(1), bbox: zeldaObjects.get(6) }
        { character: zeldaObjects.get(5), bbox: zeldaObjects.get(2) }
        { character: zeldaObjects.get(5), bbox: zeldaObjects.get(6) }
      ]

    it 'does not mistakenly include other objects based on values alone', ->
      cf = typeFilter 'character'
      bf = typeFilter 'hat'
      expectIs searchZelda([cf,bf]), imm [
        { character: zeldaObjects.get(1), hat: zeldaObjects.get(8) }
        { character: zeldaObjects.get(5), hat: zeldaObjects.get(8) }
      ]

  describe 'with joins', ->
    charFilter = imm
      match: { type: 'character' }

    boxFilter = imm
      match: { type: 'bbox' }
      join: 'character.eid'

    heroTagFilter = imm
      match:
        type: 'tag'
        value: 'hero'
      join: 'character.eid'

    it 'constrains results by matching joined attributes', ->

      expectIs searchZelda([charFilter, boxFilter]), imm [
        { character: zeldaObjects.get(1), bbox: zeldaObjects.get(2) }
        { character: zeldaObjects.get(5), bbox: zeldaObjects.get(6) }
      ]

    it 'joins and filters on multiple components', ->
      filters = [
        charFilter
        boxFilter
        heroTagFilter
      ]
      expectIs searchZelda(filters), imm [
        { character: zeldaObjects.get(1), bbox: zeldaObjects.get(2), tag: zeldaObjects.get(0) }
      ]

    it 'does nothing with superfluous joins', ->
      f =
        match: { type: 'character' }
        join: 'super.fluous'

      expectIs searchZelda([f]), imm([
        { character: zeldaObjects.get(1) }
        { character: zeldaObjects.get(5) }
      ])
