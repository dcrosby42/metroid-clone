React = require 'react'
Immutable = require 'immutable'
Map = Immutable.Map
List = Immutable.List
Set = Immutable.Set
imm = Immutable.fromJS

InspectorUI = React.createClass
  displayName: 'InspectorUI'
  render: ->
    React.createElement 'div', {className: 'component-inspector'},
      @props.entities.map((components,eid) =>
        React.createElement Entity, {eid: eid, components: components, key: eid, inspectorConfig: @props.inspectorConfig}
      ).toList()

Entity = React.createClass
  displayName: 'Entity'
  getInitialState: ->
    {
      foldOpen: false
    }

  headerClicked: (e) ->
    e.preventDefault()
    @setState (prev) ->
      { foldOpen: !prev.foldOpen }

  render: ->
    folder = if @state.foldOpen
        React.createElement 'span', {className: 'entity-folder open'}, "[ - ] "
      else
        React.createElement 'span', {className: 'entity-folder closed'}, "[ + ] "

    header = React.createElement 'div', {className: "entity-header", onClick: @headerClicked},
      folder
      "Entity: "
      @props.eid

    componentViews = if @state.foldOpen
      @props.components.map((comp,cid) =>
        React.createElement Component, {component: comp, key: cid, inspectorConfig: @props.inspectorConfig}
      ).toList()
    else
      List()

    React.createElement 'div', {className: 'entity'},
      header,
      componentViews


ReservedComponentKeys = Set.of('type','eid','cid')

Component = React.createClass
  displayName: 'Component'
  getInitialState: ->
    layout = @props.inspectorConfig.getIn(['componentLayout',@props.component.get('type')])
    open = if layout? then layout.get('open') else false
    {
      foldOpen: open
    }

  headerClicked: (e) ->
    e.preventDefault()
    @setState (prev) ->
      { foldOpen: !prev.foldOpen }

  render: ->
    comp = @props.component

    folder = if @state.foldOpen
        React.createElement 'span', {className: 'component-folder open'}, "[ - ] "
      else
        React.createElement 'span', {className: 'component-folder closed'}, "[ + ] "

    header = React.createElement 'div', {className: "component-header", onClick: @headerClicked},
      folder
      React.createElement 'span', {className: 'component-type'},
        comp.get('type')
      " "
      React.createElement 'span', {className: 'component-cid'},
        comp.get('cid')

    if @state.foldOpen
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

    else
      React.createElement 'div', {className: 'component'},
        header

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
    
module.exports = InspectorUI

