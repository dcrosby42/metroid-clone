Immutable = require 'immutable'
imm = Immutable.fromJS

chai = require('chai')
expect = chai.expect
assert = chai.assert
expectIs = require('../helpers/expect_helpers').expectIs

FilterExpander = require '../../src/javascript/ecs2/filter_expander'
# expandFilter  = FilterExpander.expandFilter
# expandLabel   = FilterExpander.expandLabel
# joinAll       = FilterExpander.joinAll

SystemExpander = require '../../src/javascript/ecs2/system_expander'
expandSystem = SystemExpander.expandSystem

describe 'expandSystem', ->
  it 'expands config.filters according to FilterExpander', ->
    filters = [ 'something' ]
    s0 = imm
      config:
        filters: filters
      update: (_) ->
      type: 'a'
    s1 = expandSystem(s0)

    expectedFilters = FilterExpander.expandFilterGroups(filters)
    expectedSystem = s0.setIn(['config','filters'],expectedFilters)
    expectIs s1, expectedSystem

  it 'defaults type to "iterating-updating"', ->
    s0 = imm
      config:
        filters: []
      update: (_) ->

    s1 = expandSystem(s0)
    expectIs s1.get('type'), 'iterating-updating'

  it 'does not carp if no filters are present', ->
    s0 = imm
      type: "something"
      config:
        what: 'evar'
      update: (_) ->
    
    expectIs expandSystem(s0), s0




    

