EntitySearch = require '../../src/javascript/ecs2/entity_search'

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

module.exports = TestHelpers
