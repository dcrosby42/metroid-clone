React = require 'react'
Immutable = require 'immutable'
{OrderedMap,Map,List,Set} = Immutable

RollingHistory = require '../utils/rolling_history'
EntityStore = require '../ecs/entity_store'

{div,span,table,tbody,td,tr} = React.DOM

# ComponentSearchBox = require './component_search_box'

# ReservedComponentKeys = Set.of('type','eid','cid')
      # pairs = comp.filterNot((value,key) -> ReservedComponentKeys.contains(key))

Structures = require './structures'


EntityInspector={}
EntityInspector.create = (h) ->
  gameState = RollingHistory.current(h).get('gameState')
  # console.log gameState.toJS()

  # [entities,_] = groupComponentsByEntity(gameState)
  entities = groupComponentsByEntity(gameState)
  # console.log entities.toJS()
  # entities = sortEntityMap(entities)


  # entities = entities.reduce (memo,comps,eid) ->
  #   [newVal,newKey] = modify(comps,eid)
  #   memo.set(newKey,newVal)
  # , OrderedMap()

  React.createElement Structures.Map, data: entities


groupComponentsByEntity = (gameState) ->
  compStore = gameState.get('compStore')
  data = compStore.get('data')
  indexed = compStore.getIn(['indexedData',EntityStore.EidTypeIndex])
  # console.log indexed.toJS()
  sortEntityMap(indexed)
    .reduce (result,cidsByType,eid) ->
      compsByType = cidsByType.map((cidSet) -> cidSet.valueSeq().map((cid) -> data.get(cid)))
      # console.log compsByType.toJS()
      newKey = if compsByType.get('name')?
        # console.log "  name",compsByType.get('name').get(0)
        "#{compsByType.getIn(['name',0,'name'])} (#{eid})"
      else
        eid
      result.set newKey, compsByType
    , OrderedMap()


  # estore = new EntityStore(gameState)
  #
  # entities = Map()
  # estore.forEachComponent (comp) ->
  #   eid = comp.get('eid')
  #   cid = comp.get('cid')
  #   entities = entities.updateIn([eid,cid], List(), (comps) -> comps.push(comp))
  #   
  #
  # [entities,estore]

sortEntityMap = (em) ->
  em.sortBy((_,key) -> parseInt(key[1..-1]))

modify = (comps,eid) ->
  newKey = eid
  name = null
  newComps = OrderedMap()
  sortEntityMap(comps).forEach (compL,cid) ->
    friendlyKey = compL.get(0).get('type')
    if friendlyKey == 'name'
      name = compL.get(0).get('name')

    newComps = newComps.set(friendlyKey,compL)
    if friendlyKey == "missile_container"
      console.log "missilie_container compL",compL.toJS()

  if name?
     newKey = "#{name} (#{eid})"
     # newKey = name
  [newComps,newKey]

module.exports = EntityInspector

