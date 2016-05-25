React = require 'react'
Immutable = require 'immutable'
{OrderedMap,Map,List,Set} = Immutable

RollingHistory = require '../utils/rolling_history'
EntityStore = require '../ecs/entity_store'

{div,span,table,tbody,td,tr} = React.DOM

Structures = require './structures'

 #shouldComponentUpdate: function(nextProps, nextState) {
EntityInspector={}
EntityInspector.create = (h) ->
  gameState = RollingHistory.current(h).get('gameState')

  entities = groupComponentsByEntity(gameState)

  React.createElement Structures.FilterableMap, data: entities


groupComponentsByEntity = (gameState) ->
  compStore = gameState.get('compStore')
  data = compStore.get('data')
  indexed = compStore.getIn(['indexedData',EntityStore.EidTypeIndex])
  sortEntityMap(indexed)
    .reduce (result,cidsByType,eid) ->
      compsByType = cidsByType.map((cidSet) -> cidSet.valueSeq().map((cid) -> data.get(cid)))
      newKey = if compsByType.hasIn(['name',0])
        "#{compsByType.getIn(['name',0,'name'])} (#{eid})"
      else
        eid
      result.set newKey, compsByType
    , OrderedMap()

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
  [newComps,newKey]

module.exports = EntityInspector

