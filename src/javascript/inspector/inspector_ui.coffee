React = require 'react'
Immutable = require 'immutable'
Map = Immutable.Map
List = Immutable.List
Set = Immutable.Set
imm = Immutable.fromJS

{div,span,table,tbody,td,tr} = React.DOM

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
        span {className: 'inspector-folder open'}, "- "
      else
        span {className: 'inspector-folder closed'}, "+ "

    header = div {className: "inspector-header", onClick: @headerClicked}, folder, "Entity Inspector"

    views = []
    if @state.foldOpen
      countComps = (sum,comps) -> sum + comps.size
      views.push(
        div {className: 'entitiesSummary'},
          "#{@props.entities.size} entities, #{@props.entities.valueSeq().reduce(countComps, 0)} components"
      )
      views.push(
        div {className: 'entities'},
          @props.entities.map((components,eid) =>
            React.createElement Entity, {eid: eid, components: components, key: eid, inspectorConfig: @props.inspectorConfig}
          ).toList()
      )

    if @state.showSearchBox
      views.push(
        React.createElement ComponentSearchBox, {key: 'component-search-box', entityStore: @props.entityStore}
      )

    div {className: 'component-inspector'},
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
        span {className: 'entity-folder open'}, "[ - ] "
      else
        span {className: 'entity-folder closed'}, "[ + ] "

    nameLabel = "Entity #{@props.eid}"
    @props.components.forEach (comp,cid) =>
      if comp.get('type') == 'name'
        nameLabel = comp.get('name') + " (#{@props.eid})"

    header = div {className: "entity-header", onClick: @headerClicked},
      folder
      nameLabel

    componentViews = if @state.foldOpen
      @props.components.map((comp,cid) =>
        React.createElement Component, {component: comp, key: cid, inspectorConfig: @props.inspectorConfig}
      ).toList()
    else
      List()


    div {className: 'entity'},
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
        span {className: 'component-folder open'}, "[ - ] "
      else
        span {className: 'component-folder closed'}, "[ + ] "

    header = div {className: "component-header", onClick: @headerClicked},
      folder
      span {className: 'component-type'},
        comp.get('type')
      " "
      span {className: 'component-cid'},
        comp.get('cid')

    if @state.foldOpen
      pairs = comp.filterNot((value,key) -> ReservedComponentKeys.contains(key))
      rows = pairs.map((value,key) ->
        React.createElement PropRow, {key: key, name: key, value: value}
      ).toList()

      props = table {className: 'component-props'},
        tbody null,
        rows

      div {className: 'component'},
        header,
        props

    else
      div {className: 'component'},
        header

PropRow = React.createClass
  displayName: 'PropRow'
  render: ->
    tr null,
      td {className:'prop-name'}, @props.name
      React.createElement PropValueCell, {value: @props.value}

PropValueCell = React.createClass
  displayName: 'PropValueCell'
  render: ->
    val = if @props.value? then @props.value.toString() else "?"
    td {className:'prop-value'}, val
    
module.exports = InspectorUI

