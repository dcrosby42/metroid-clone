C = require '../components'

class EntitySearchFilter
  constructor: (@compType,@matchers=null) ->
    @hasMatchers = if @matchers? then @matchers.length > 0 else false

  satisfiedBy: (comp) ->
    return true unless @hasMatchers
    for matcher in @matchers
      key = matcher[0]
      val = matcher[1]
      if comp[key] != val
        # console.log "No match: key=#{key} val=#{val} comp[#{key}]=#{comp[key]}"
        return false
    return true

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
    @eid = 0

class EntitySearchCompoundResult
  constructor: (@width) ->
    @results = new Array(@width)

class PreparedSearcher
  constructor: (@query) ->

  run: (estore,fn) ->
    doSearch estore,@query,fn
  #TODO runParam

class PreparedCompoundSearcher
  constructor: (@compoundQuery) ->

  run: (estore,fn) ->
    doCompoundSearch(estore,@compoundQuery,fn)
  #TODO runParam
    

badFilterSpec = (x) ->
  throw new Error("EntitySearch.expandFilter: cannot grok filter spec... perhaps undefined Type?",x)
  
expandFilter = (fspec) ->
  badFilterSpec(fspec) unless fspec?
  if fspec.constructor == EntitySearchFilter
    return fspec
  else if typeof fspec == 'object' and fspec.type? and C.Types.exists(fspec.type)
    empty = C.Types.classFor(fspec.type).default()
    matchers = null
    for key,val of fspec
      if key != 'type' and typeof empty[key] != 'undefined' # eligible matchers only plz
        matchers ?= []
        matchers.push [key,val]
    return new EntitySearchFilter(fspec.type, matchers)
  else if C.Types.exists(fspec)
    return new EntitySearchFilter(fspec)
  else
    badFilterSpec(fspec)

expandFilters = (list) ->
  expandFilter(fspec) for fspec in list

isArray = (a) ->
  if a? and typeof a.length == 'number'
    return true
  else
    return false

prepareSearcher = (criteria) ->
  if isArray(criteria)
    if isArray(criteria[0])
      queries = []
      for list,i in criteria
        queries[i] = new EntitySearchQuery(expandFilters(list))
      cquery = new EntitySearchCompoundQuery(queries)
      return new PreparedCompoundSearcher(cquery)
    else
      query = new EntitySearchQuery(expandFilters(criteria))
      return new PreparedSearcher(query)
  else
    msg = "!! EntitySearch.prepareSearcher: must be an array of filterspecs, or an array thereof"
    console.log msg,criteria
    throw new Error("#{msg}, got #{JSON.stringify(criteria)}")


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
      if filter.satisfiedBy(comp)
        # TODO: dedupe this?
        result.entity = estore.getEntity(comp.eid) # THIS LINE IS NOT DUPED IN recurseSearch
        result.eid = result.entity.eid # convenience for Systems
        result.comps[slot] = comp
        nextSlot = slot+1
        if nextSlot == result.width
          handler(result)
        else
          recurseSearch(estore,query,handler,nextSlot,result)
  else
    console.log "!! EntitySearch TODO: support entity searches without compType"
  
  # TODO: support filter.eid right off the bat? not likely needed, given EntityStore.getEntity
  result.comps[slot] = null
  result.entity = null
  result.eid = 0
  null

#
# Recursion for query slots 1-n
#
recurseSearch = (estore,query,handler,slot,result) ->
  filter = query.filters[slot]
  if filter.compType?
    result.entity.each filter.compType, (comp) ->
      if filter.satisfiedBy(comp)
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
    cres = cresult.results
    if qnum > 0 and res.entity.eid == cres[qnum-1].entity.eid
      # Don't match entities up with themselves
      return
    cresult.results[qnum] = res
    nextq = qnum+1
    if nextq == cresult.width
      # Invoke the result handler with appropriate number of args:
      # cres = cresult.results
      if cresult.width == 1
        handler(cres[0])
      else if cresult.width == 2
        handler(cres[0], cres[1])
      else if cresult.width == 3
        handler(cres[0], cres[1], cres[2])
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

  filter: (compType,matchers=null) -> new EntitySearchFilter(compType,matchers)
  query: (filters) -> new EntitySearchQuery(filters)
  compoundQuery: (queries) -> new EntitySearchCompoundQuery(queries)
  prepare: (criteria) -> prepareSearcher(criteria)
  _expandFilter: (fspec) -> expandFilter(fspec)

