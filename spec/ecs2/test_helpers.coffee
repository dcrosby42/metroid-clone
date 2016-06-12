_ = require 'lodash'
EntitySearch = require '../../src/javascript/ecs2/entity_search'
TestHelpers = require './test_helpers'

chai = require('chai')
expect = chai.expect


TestHelpers =
  copyArray: (arr) ->
    res = new Array(arr.length)
    for x,i in arr
      res[i] = x
    res

  searchEntities: (estore, criteria) ->
    ents = []
    EntitySearch.prepare(criteria).run estore, (r) -> ents.push r.entity
    ents

  searchComps: (estore, criteria) ->
    ents = []
    EntitySearch.prepare(criteria).run estore, (r) -> ents.push TestHelpers.copyArray(r.comps)
    ents

  compListEquals: (cla,clb) ->
    diff = _.differenceWith(cla,clb,TestHelpers.compEquals) 
    diff.length == 0

  compEquals: (a,b) ->
    if !(a?)
      console.log "!! compEquals a is null"
      return false
    if !b?
      console.log "!! compEquals b is null"
      return false
    return a.equals(b)
   
  assertResultComps: (gots,expects) ->
    diff1 = _.differenceWith(expects,gots,TestHelpers.compListEquals)
    expect(diff1,"missing some expected comps #{JSON.stringify(diff1)}").to.be.empty
    diff2 = _.differenceWith(gots,expects,TestHelpers.compListEquals)
    expect(diff2,"found extra comps #{JSON.stringify(diff2)}").to.be.empty

module.exports = TestHelpers
