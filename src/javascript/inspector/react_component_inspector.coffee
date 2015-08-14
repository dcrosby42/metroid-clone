React = require 'react'
Immutable = require 'immutable'
Map = Immutable.Map
List = Immutable.List
Set = Immutable.Set
imm = Immutable.fromJS

InspectorUI = require './inspector_ui'

class ReactComponentInspector
  constructor: ({@mountNode,@inspectorConfig}) ->
    @_resetEntities()
    @_renderInspector()

  update: (comp) ->
    eid = comp.get('eid')
    cid = comp.get('cid')
    @entities = @entities.setIn [eid,cid], comp

  sync: ->
    @_renderInspector()

  _resetEntities: ->
    @entities = Map({})
    
  _renderInspector: (estore) ->
    inspectorUI = React.createElement(InspectorUI, entities: @entities, inspectorConfig: @inspectorConfig, entityStore: estore)
    React.render(inspectorUI, @mountNode)
    @_resetEntities()

module.exports = ReactComponentInspector

# sampleData = Map
#   e24: Map
#     c7: Map(cid: "c7", eid: "e24", type: "controller", inputName: "player1", states: Map({ left: false, jump: true }) )
#     c3: Map(cid: "c3", eid: "e1", type: "samus", who: "knows", wat: 123.123)
#   e29: Map
#     c9: Map(cid: "c9", eid: "e24", type: "controller", inputName: "player2", states: Map({ right: true }) )
#     c99: Map(cid: "c99", eid: "e1", type: "samus", who: "doctor")
