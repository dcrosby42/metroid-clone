React = require 'react'
Immutable = require 'immutable'
Map = Immutable.Map
List = Immutable.List
Set = Immutable.Set
imm = Immutable.fromJS

ComponentSearchBox = require './component_search_box'

InspectorUI = React.createClass
  displayName: 'InspectorUI'
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
        React.DOM.span {className: 'inspector-folder open'}, "- "
      else
        React.DOM.span {className: 'inspector-folder closed'}, "+ "

    header = React.DOM.div {className: "inspector-header", onClick: @headerClicked}, folder, "Entity Inspector"

    views = if @state.foldOpen
      List([
        React.DOM.div {className: 'entities'},
          @props.entities.map((components,eid) =>
            React.createElement Entity, {eid: eid, components: components, key: eid, inspectorConfig: @props.inspectorConfig}
          ).toList()
        React.createElement ComponentSearchBox, {key: 'component-search-box', entityStore: @props.entityStore}
      ])
    else
      List()

    React.DOM.div {className: 'component-inspector'},
      header,
      views

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
        React.DOM.span {className: 'entity-folder open'}, "[ - ] "
      else
        React.DOM.span {className: 'entity-folder closed'}, "[ + ] "

    header = React.DOM.div {className: "entity-header", onClick: @headerClicked},
      folder
      "Entity: "
      @props.eid

    componentViews = if @state.foldOpen
      @props.components.map((comp,cid) =>
        React.createElement Component, {component: comp, key: cid, inspectorConfig: @props.inspectorConfig}
      ).toList()
    else
      List()

    React.DOM.div {className: 'entity'},
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
        React.DOM.span {className: 'component-folder open'}, "[ - ] "
      else
        React.DOM.span {className: 'component-folder closed'}, "[ + ] "

    header = React.DOM.div {className: "component-header", onClick: @headerClicked},
      folder
      React.DOM.span {className: 'component-type'},
        comp.get('type')
      " "
      React.DOM.span {className: 'component-cid'},
        comp.get('cid')

    if @state.foldOpen
      pairs = comp.filterNot((value,key) -> ReservedComponentKeys.contains(key))
      rows = pairs.map((value,key) ->
        React.createElement PropRow, {key: key, name: key, value: value}
      ).toList()

      props = React.DOM.table {className: 'component-props'},
        React.DOM.tbody null,
        rows

      React.DOM.div {className: 'component'},
        header,
        props

    else
      React.DOM.div {className: 'component'},
        header

PropRow = React.createClass
  displayName: 'PropRow'
  render: ->
    React.DOM.tr null,
      React.DOM.td {className:'prop-name'}, @props.name
      React.createElement PropValueCell, {value: @props.value}

PropValueCell = React.createClass
  displayName: 'PropValueCell'
  render: ->
    val = if @props.value? then @props.value.toString() else "?"
    React.DOM.td {className:'prop-value'}, val
    
module.exports = InspectorUI

