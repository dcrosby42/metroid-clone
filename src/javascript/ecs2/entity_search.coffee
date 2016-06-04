C = require '../components'

class EntitySearchResult
  constructor: (@width) ->
    @entity = null
    @comps = new Array(@width)

  backupTo: (slot) ->


class EntitySearchQuery
  constructor: (@filters) ->
    @width = @filters.length
    @_result = new EntitySearchResult(@width)

  toString: ->
    s = "(EntitySearch.Query filters: ["
    for f in @filters
      s += " " + f.toString()
    s += "])"

  newResult: ->
    return new EntitySearchResult(@width)

class EntitySearchFilter
  constructor: (@compType) ->
  toString: ->
    # "(compType: #{C.Types.nameFor(@compType)})"
    C.Types.nameFor(@compType)

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
  result.comps[slot] = null

  # TODO: support "left join" situations, ie, filter steps that are acceptable to miss

module.exports =
  run: doSearch
  Query: EntitySearchQuery
  Result: EntitySearchResult
  Filter: EntitySearchFilter

