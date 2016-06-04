C = require '../components'

class EntitySearchFilter
  constructor: (@compType) ->
  toString: ->
    C.Types.nameFor(@compType)


class EntitySearchQuery
  constructor: (@filters) ->
    @width = @filters.length

  newResult: ->
    return new EntitySearchResult(@width)

  toString: ->
    s = "(EntitySearch.Query filters: ["
    for f in @filters
      s += " " + f.toString()
    s += "])"
    s


class EntitySearchCompoundQuery
  constructor: (@queries) ->
    @width = @queries.length

  toString: ->
    s = "(EntitySearch.CompoundQuery queries: "
    for q in @queries
      s += " " + q.toString()
    s += ")"
    s

  newResult: ->
    return new EntitySearchCompoundResult(@width)

class EntitySearchResult
  constructor: (@width) ->
    @entity = null
    @comps = new Array(@width)

class EntitySearchCompoundResult
  constructor: (@width) ->
    @results = new Array(@width)


#
# estore: EntityStore
# query: EntitySearch.Query with one or more filters
# handler: func(result)
#
doSearch = (estore,query,handler) ->
  result = query.newResult()
  slot = 0
  filter = query.filters[slot]  # TODO: handle empty filters
  if filter.compType?
    estore.each filter.compType, (comp) ->
      # TODO: dedupe this
      result.entity = estore.getEntity(comp.eid) # THIS LINE IS NOT DUPED IN run2
      result.comps[slot] = comp
      nextSlot = slot+1
      if nextSlot == result.width
        handler(result)
      else
        recurseSearch(estore,query,handler,nextSlot,result)
  else
    console.log "!! EntitySearch TODO: support entity searches without compType"
  
  # TODO: support filter.eid right off the bat?
  result.comps[slot] = null
  null

#
# Recursion for query slots 1-n
#
recurseSearch = (estore,query,handler,slot,result) ->
  filter = query.filters[slot]
  if filter.compType?
    result.entity.each filter.compType, (comp) ->
      # TODO: dedupe this
      result.comps[slot] = comp
      nextSlot = slot+1
      if nextSlot == result.width
        handler(result)
      else
        recurseSearch(estore,query,handler,nextSlot,result)
  else
    console.log "!! EntitySearch.run2 TODO: support entity searches without compType"
  
  # TODO: support "left join" situations, ie, filter steps that are acceptable to miss
  result.comps[slot] = null
  null

#
# estore: EntityStore
# cquery: EntitySearch.CompoundQuery with one or more EntitySearch.Query
# handler: func(r0,r1,...rN) where N is the number of Query objects in CompoundQuery
#
doCompoundSearch = (estore, cquery, handler) ->
  recurseCompoundSearch(estore, cquery, handler, 0, cquery.newResult())
  null

recurseCompoundSearch = (estore, cquery, handler, qnum, cresult) ->
  null
  query = cquery.queries[qnum]
  doSearch estore, query, (res) ->
    cresult.results[qnum] = res
    nextq = qnum+1
    if nextq == cresult.width
      # Invoke the result handler with appropriate number of args:
      res = cresult.results
      if cresult.width == 1
        handler(res[0])
      else if cresult.width == 2
        handler(res[0], res[1])
      else if cresult.width == 3
        handler(res[0], res[1], res[2])
      else
        handler(cresult.results...)
    else
      recurseCompoundSearch(estore, cquery, handler, nextq, cresult)
  cresult.results[qnum] = null
  null


module.exports =
  run: doSearch
  runCompound: doCompoundSearch

  Filter: EntitySearchFilter
  Query: EntitySearchQuery
  CompoundQuery: EntitySearchCompoundQuery
  Result: EntitySearchResult

