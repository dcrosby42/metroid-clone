React = require 'react'
{div,span,table,tbody,td,tr,th,ul,li} = React.DOM
Immutable = require 'immutable'
{Map,Set,Seq,List}=Immutable
classNames = require 'classnames'
RollingHistory = require '../utils/rolling_history'

scalarTypes = Set(['string','number','boolean'])
autoOpenKeys = Set(['lookup','index','keypath'])

isScalar = (x) ->
  !x? or scalarTypes.has(typeof x)

isShortList = (x) ->
  false
  # (Seq.isSeq(x) or Set.isSet(x) or List.isList(x)) and (x.size <= 1)
  # x.size <= 1

autoOpenKey = (key) ->
  autoOpenKeys.has(key)

autoOpenVal = (val) ->
  isScalar(val) or isShortList(val)

valueToElement = (val,startUnfolded=false) ->
  if Map.isMap(val)
    React.createElement MapEl, data: val, startUnfolded: startUnfolded
  else if List.isList(val) or Seq.isSeq(val)
    React.createElement ListEl, data: val, startUnfolded: startUnfolded
  else if Set.isSet(val)
    React.createElement ListEl, data: val.valueSeq(), startUnfolded: startUnfolded
  else
    if val?
      val.toString()
    else
      "(null)"

ListEl = React.createClass
  displayName: 'ListEl'
  render: ->
    items = []
    @props.data.forEach (val,i) =>
      items.push li {key:"item-#{i}",className:'listItem'}, valueToElement(val,@props.startUnfolded)
    ul {className:classNames('list',@props.className)},
      items

MapEntryEl = React.createClass
  displayName: 'MapEntryEl'
  getInitialState: ->
    { folded: !@props.startUnfolded and !autoOpenVal(@props.val) and !autoOpenKey(@props.keystr) }
  render: ->
    if @state.folded
      tr {className:'mapEntry', key:@props.keystr },
        th {className:'mapKey', onClick: @toggleFold}, @props.keystr, "..."
        td {className:'mapValue'}, ""
    else
      tr {className:'mapEntry', key:@props.keystr, onClick: @clicked},
        th {className:'mapKey', onClick: @toggleFold}, @props.keystr
        td {className:'mapValue'}, valueToElement(@props.val,@props.startUnfolded)

  toggleFold: (e) ->
    @setState (s) -> { folded: !s.folded }
    e.preventDefault()

  
MapEl = React.createClass
  displayName: 'MapEl'

  render: ->
    if @props.data?
      rows = []
      @props.data.forEach (val,key) =>
        rows.push React.createElement MapEntryEl, key:key, keystr:key,val:val, startUnfolded: @props.startUnfolded
      table {className:classNames('map',@props.className)},
        tbody {},
          rows
    else
      React.createElement 'span', null, "NULL"

filterMap = require '../utils/filter_map'

FilterableMap = React.createClass
  displayName: 'FilterableMap'
  getInitialState: ->
    {
      filterText: ''
    }

  handleFilterChange: (e) ->
    @setState { filterText: e.target.value }

  render: ->
    filtered = filterMap(@props.data,@state.filterText)
    # startUnfolded = !Immutable.is(@props.data, filtered)
    div {},
      React.createElement 'input', {type:'text',value:@state.filterText, placeholder: "(filter)", onChange: @handleFilterChange }
      React.createElement MapEl, data: filtered#, startUnfolded: startUnfolded

 #shouldComponentUpdate: function(nextProps, nextState) {

module.exports =
  Map: MapEl
  List: ListEl
  MapEntry: MapEntryEl
  FilterableMap: FilterableMap

