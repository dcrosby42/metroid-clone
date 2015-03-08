Immutable = require 'immutable'
imm = Immutable.fromJS

chai = require('chai')
expect = chai.expect
assert = chai.assert
expectIs = require('../helpers/expect_helpers').expectIs

FilterExpander = require '../../src/javascript/ecs2/filter_expander'
expandFilters = FilterExpander.expandFilters
expandFilter  = FilterExpander.expandFilter
expandLabel   = FilterExpander.expandLabel
joinAll       = FilterExpander.joinAll
  

describe 'expandFilter', ->
  it 'assumes a bare string is a type matcher', ->
    expectIs expandFilter('sword'), imm
      match:
        type: 'sword'
      as: 'sword'

  it 'does nothing if match and as are set', ->
    f = imm
      match: { name: "charles" }
      as: 'namer'
    expectIs expandFilter(f), f

  it 'simply converts to immutable struct if "match" and "as" are set', ->
    f =
      match: { name: "charles" }
      as: 'namer'
    expectIs expandFilter(f), Immutable.fromJS(f)

  it 'converts match from a string to a "type" matcher', ->
    f = { match: 'dude' }
    expectIs expandFilter(f), imm
      match:
        type: 'dude'
      as: 'dude'

describe 'expandFilters', ->
  it 'expands all filters and joins on eid', ->
    q = [ 'character', 'weapon', 'hitbox', 'stats' ]
    expectIs expandFilters(q), imm [
      {
        match: { type: 'character' }
        as: 'character'
      }
      {
        match: { type: 'weapon' }
        as: 'weapon'
        join: 'character.eid'
      }
      {
        match: { type: 'hitbox' }
        as: 'hitbox'
        join: 'character.eid'
      }
      {
        match: { type: 'stats' }
        as: 'stats'
        join: 'character.eid'
      }
    ]

describe 'expandLabel', ->
  it 'does nothing if "as" is set already', ->
    f = imm
      match: { a: "thing" }
      as: "target"
    expectIs expandLabel(f), f

  it 'will use the first matcher value for "as"', ->
    f = imm
      match: { size: 'big', name: 'jim' }

    expectIs expandLabel(f), imm
      match: { size: 'big', name: 'jim' }
      as: 'big'

  it 'will prefer the value of the "type" matcher value, if present', ->
    f = imm
      match: { size: 'big', type: 'earthworm', name: 'jim' }

    expectIs expandLabel(f), imm
      match: { size: 'big', type: 'earthworm', name: 'jim' }
      as: 'earthworm'

describe 'joinAll', ->
  f1 = imm
    match: { type: 'character' }
    as: 'character'
  f2 = imm
    match: { type: 'armor' }
    as: 'armor'
  f3 = imm
    match: { type: 'rectangle' }
    as: 'rectangle'


  it 'adds "join" to all but the first filter, joining to an attribute of the first filter', ->
    filters = Immutable.List.of f1, f2, f3
    expectIs joinAll(filters,'anAtt'), imm [
      f1
      f2.set('join', 'character.anAtt')
      f3.set('join', 'character.anAtt')
    ]

  it 'does not overwrite preexisting joins', ->
    filters = imm [
      f1
      f2.set('join', null)
      f3.set('join', 'armor.owner')
    ]
    expectIs joinAll(filters,'whatev'), filters

  it 'does nothing if only one filter is given', ->
    filters = imm [ f1 ]
    expectIs joinAll(filters,'whatev'), filters

  it 'does nothing if empty list given', ->
    filters = imm []
    expectIs joinAll(filters,'whatev'), filters


      

