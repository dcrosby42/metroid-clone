React = require 'react'
Immutable = require 'immutable'
Map = Immutable.Map
List = Immutable.List
Set = Immutable.Set
imm = Immutable.fromJS

ReservedComponentKeys = Set.of('type','eid','cid')

ComponentInspector = React.createClass
  displayName: 'ComponentInspector'
  render: ->
    React.createElement 'div', {className: 'component-inspector'}, @props.children

Entity = React.createClass
  displayName: 'Entity'
  render: ->
    entity = @props.entity
    header = React.createElement 'div', {className: "entity-header"},
      "Entity: "
      entity.get('eid')

    comps = entity.get('components')
    componentViews = comps.map (comp) ->
      React.createElement Component, {component: comp}

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


    pairs = comp.filterNot((prop,name) -> ReservedComponentKeys.contains(name))
    props = React.createElement 'table', {className: 'component-props'},
      React.createElement 'tbody', null,
        pairs.map (prop,name) ->
          React.createElement 'tr', null,
            React.createElement 'td', {className:'prop-name'}, name
            React.createElement 'td', {className:'prop-value'}, prop.toString()

    React.createElement 'div', {className: 'component'},
      header,
      props


# ------------------------------

class ReactComponentInspector
  constructor: (mountNode) ->
    entity = Map
      eid: "e24"
      components: List.of(
        Map(cid: "c7", eid: "e24", type: "controller", inputName: "player1", states: Map({ left: false, jump: true }) )
        Map(cid: "c3", eid: "e1", type: "samus", who: "knows")
      )
    entityView = React.createElement Entity, {entity: entity}
    inspectorView = React.createElement ComponentInspector, {},
      entityView
    React.render inspectorView, mountNode

  update: (comp) ->

module.exports = ReactComponentInspector

