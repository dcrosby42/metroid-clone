# Finder = require '../../src/javascript/search/immutable_object_finder'
Immutable = require 'immutable'
ExpectHelpers = require '../helpers/expect_helpers'
expectIs = ExpectHelpers.expectIs

ObjectStore = require '../../src/javascript/search/object_store'
ObjectStoreSearch = require '../../src/javascript/search/object_store_search'

util = require 'util'

chai = require('chai')
expect = chai.expect
assert = chai.assert

imm = Immutable.fromJS
immset = (xs...) -> Immutable.Set(xs)
Set = Immutable.Set
Map = Immutable.Map
List = Immutable.List

jsonFmt = (immobj) -> JSON.stringify(immobj.toJS(),null,4)

zeldaObjects = imm [
  { cid: 'c1', eid: 'e1', type: 'tag', value: 'hero' }
  { cid: 'c2', eid: 'e1', type: 'character', name: 'Link' }
  { cid: 'c3', eid: 'e1', type: 'bbox', shape: [1,2,3,4] }
  { cid: 'c4', eid: 'e1', type: 'inventory', stuff: 'items' }

  { cid: 'c5', eid: 'e2', type: 'tag', value: 'enemy' }
  { cid: 'c6', eid: 'e2', type: 'character', name: 'Tektike' }
  { cid: 'c7', eid: 'e2', type: 'bbox', shape: [3,4,5,6] }
  { cid: 'c8', eid: 'e2', type: 'digger', status: 'burrowing' }

  { cid: 'c9', eid: 'e1', type: 'hat', color: 'green' }
  { cid: 'c10', eid: 'e99', extraneous: 'hat', type: 'other-thing', sha: 'zam' }
]

describe "ObjectStoreSearch", ->
  indices = imm([
    ['eid']
    ['type']
    ['eid','type']
  ])
  store = ObjectStore.create('cid', indices)
  store = ObjectStore.addObjects(store, zeldaObjects)

  describe "convertMatchesToIndexLookups", ->
    cases = [
      [
        "a single-field match that aligns with single-field index"
        { match: { type: 'character' } }
        { lookup: { index: ['type'], keypath: ['character'] } }
      ]
      [
        "another single-field match that aligns with single-field index"
        { match: { eid: '123' } }
        { lookup: { index: ['eid'], keypath: ['123'] } }
      ]
      [
        "a multi-field match that aligns with multi-field index"
        { match: { eid: '123', type: 'weapon'} }
        { lookup: { index: ['eid','type'], keypath: ['123','weapon'] } }
      ]
      [
        "a multi-field match, plus others, that aligns with multi-field index"
        { match: { eid: '123', type: 'weapon', other: 'info' } }
        { match: { other: 'info' }, lookup: { index: ['eid','type'], keypath: ['123','weapon'] } }
      ]
      [
        "a match where no fields are indexed"
        { match: { main: 'stuff', other: 'info' } }
        { match: { main: 'stuff', other: 'info' } }
      ]
    ]
    makeTest = ([desc,input,expected]) ->
      ->
        res = ObjectStoreSearch.convertMatchesToIndexLookups(imm(input), indices)
        expectIs res, imm(expected)

    it "transforms filter with #{c[0]}", makeTest(c) for c in cases

  describe "search", ->
    cases = [
      [
        "simple type-based match on 'tag'"
        [ { as: 'tag', match: { type: 'tag' } } ]
        [ {tag:'c1'},{tag:'c5'} ]
      ]
      [
        "simple type-based match on 'character'"
        [ { as: 'character', match: { type: 'character' } } ]
        [ { character: 'c2' }, { character: 'c6' } ]
      ]
      [
        "indexed lookup on type=character"
        [ { as: 'character', lookup: { index: ['type'], keypath:['character']}}]
        [ { character: 'c2' }, { character: 'c6' } ]
      ]
      [
        "multi-filter match, joined using character.eid placeholder in second match"
        [
          { as: 'character', match: { type: 'character' } }
          { as: 'bbox', match: { type: 'bbox', eid: ['character','eid'] } }
        ]
        [ { character: 'c2', bbox: 'c3' }, { character: 'c6', bbox: 'c7' } ]
      ]
      [
        "multi-filter indexed lookup, joined with character.eid placeholder in second keypath"
        [
          { as: 'character', lookup: { index: ['type'], keypath:['character']}}
          { as: 'bbox', lookup: { index: ['eid','type'], keypath:[['character','eid'],'bbox']}}
        ]
        [ { character: 'c2', bbox: 'c3' }, { character: 'c6', bbox: 'c7' } ]
      ]
      [
        "multi-filter indexed lookup AND match, filtering results by name=Link"
        [
          { as: 'character', match: { name: 'Link' }, lookup: { index: ['type'], keypath:['character']}}
          { as: 'bbox', lookup: { index: ['eid','type'], keypath:[['character','eid'],'bbox']}}
        ]
        [ { character: 'c2', bbox: 'c3' } ]
      ]
      [
        "multi-filter match, 'inner joined' using character.eid placeholder in second match"
        [
          { as: 'character', match: { type: 'character' } }
          { as: 'hat', match: { type: 'hat', eid: ['character','eid'] } }
        ]
        [ { character: 'c2', hat: 'c9' } ]
      ]
      [
        "multi-filter match, 'outer joined' using character.eid placeholder in second match"
        [
          { as: 'character', match: { type: 'character' } }
          { as: 'hat', match: { type: 'hat', eid: ['character','eid'] }, optional: true }
        ]
        [ { character: 'c2', hat: 'c9' }, {character: 'c6', hat: null } ]
      ]
      [
        "multi-filter indexed lookup, 'outer joined' using character.eid placeholder in second match"
        [
          { as: 'character', lookup: { index:['type'],keypath:['character'] } }
          { as: 'hat', lookup:{index:['eid','type'],keypath:[['character','eid'],'hat']}, optional: true }
        ]
        [ { character: 'c2', hat: 'c9' }, {character: 'c6', hat: null } ]
      ]
      [
        "multi-filter indexed lookup, 'outer joined', with further results beyond a missing optional"
        [
          { as: 'character', lookup: { index:['type'],keypath:['character'] } }
          { as: 'hat', lookup:{index:['eid','type'],keypath:[['character','eid'],'hat']}, optional: true }
          { as: 'tag', lookup:{index:['eid','type'],keypath:[['character','eid'],'tag']}, optional: true }
        ]
        [ { character: 'c2', hat: 'c9', tag: 'c1' }, {character: 'c6', hat: null, tag: 'c5'} ]
      ]
    ]
    
    makeDesc = (c) -> "testing #{c[0]}"
    makeTest = ([desc,filters,expected]) ->
      ->
        res = ObjectStoreSearch.search(store, imm(filters))
        expectedResults = Set(imm(expected).map (thing) ->
          imm(thing).map((v) -> store.get('data').get(v,null)))
        expectIs Set(res), expectedResults

    it makeDesc(c), makeTest(c) for c in cases
