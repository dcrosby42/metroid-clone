React = require 'react'
Immutable = require 'immutable'
Map = Immutable.Map
List = Immutable.List
Set = Immutable.Set
imm = Immutable.fromJS

ReservedComponentKeys = Set.of('type','eid','cid')

sampleData = Map
  e24: Map
    c7: Map(cid: "c7", eid: "e24", type: "controller", inputName: "player1", states: Map({ left: false, jump: true }) )
    c3: Map(cid: "c3", eid: "e1", type: "samus", who: "knows", wat: 123.123)
  e29: Map
    c9: Map(cid: "c9", eid: "e24", type: "controller", inputName: "player2", states: Map({ right: true }) )
    c99: Map(cid: "c99", eid: "e1", type: "samus", who: "doctor")

ComponentInspector = React.createClass
  displayName: 'ComponentInspector'
  render: ->
    React.createElement 'div', {className: 'component-inspector'},
      @props.entities.map((components,eid) ->
        React.createElement Entity, {eid: eid, components: components, key: eid}
      ).toList()

Entity = React.createClass
  displayName: 'Entity'
  render: ->
    header = React.createElement 'div', {className: "entity-header"},
      "Entity: "
      @props.eid

    componentViews = @props.components.map((comp,cid) ->
      React.createElement Component, {component: comp, key: cid}
    ).toList()

    React.createElement 'div', {className: 'entity'},
      header,
      componentViews

Component = React.createClass
  displayName: 'Component'
  render: ->
    comp = @props.component

    header = React.createElement 'div', {className: "component-header"},
      React.createElement 'span', {className: 'component-type'},
        comp.get('type')
      " "
      React.createElement 'span', {className: 'component-cid'},
        comp.get('cid')

    pairs = comp.filterNot((value,key) -> ReservedComponentKeys.contains(key))
    rows = pairs.map((value,key) ->
      React.createElement PropRow, {key: key, name: key, value: value}
    ).toList()

    props = React.createElement 'table', {className: 'component-props'},
      React.createElement 'tbody', null,
      rows

    React.createElement 'div', {className: 'component'},
      header,
      props

PropRow = React.createClass
  displayName: 'PropRow'
  render: ->
    React.createElement 'tr', null,
      React.createElement 'td', {className:'prop-name'}, @props.name
      React.createElement PropValueCell, {value: @props.value}

PropValueCell = React.createClass
  displayName: 'PropValueCell'
  render: ->
    val = if @props.value then @props.value.toString() else "?"
    React.createElement 'td', {className:'prop-value'}, val

# ------------------------------

class ReactComponentInspector
  constructor: (@mountNode) ->
    @_resetEntities()
    @_renderInspector()

  update: (comp) ->
    # console.log "update #{comp.toString()}"
    eid = comp.get('eid')
    cid = comp.get('cid')
    @entities = @entities.setIn [eid,cid], comp

  sync: ->
    # console.log "SYNC"
    @_renderInspector()
    
  _renderInspector: ->
    React.render(
      React.createElement(ComponentInspector, entities: @entities)
      @mountNode
    )
    @_resetEntities()

  _resetEntities: ->
    @entities = Map({})
    
module.exports = ReactComponentInspector

