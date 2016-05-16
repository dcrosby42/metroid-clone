# ReactComponentInspector = require './react_component_inspector'
React = require 'react'
Immutable = require 'immutable'
{Map,List} = Immutable

RollingHistory = require '../utils/rolling_history'
EntityStore = require '../ecs/entity_store'
InspectorUI = require './inspector_ui'

# module.exports =
#   createComponentInspector: (args...) ->
#     new ReactComponentInspector(args...)

exports.createEntityInspector = (h) ->
  gameState = RollingHistory.current(h).get('gameState')
  estore = new EntityStore(gameState)

  entities = Map()
  estore.forEachComponent (comp) ->
    eid = comp.get('eid')
    cid = comp.get('cid')
    entities = entities.setIn([eid,cid], comp)

  React.createElement InspectorUI,
    entities: entities
    entityStore: estore
    inspectorConfig: Immutable.fromJS
      componentLayout:
        samus:      { open: false }
        skree:      { open: false }
        zoomer:      { open: false }
        hit_box:      { open: false }
        controller: { open: false }
        animation:     { open: false }
        velocity:   { open: false }
        position:   { open: false }
