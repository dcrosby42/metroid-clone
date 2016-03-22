React = require 'react'
Immutable = require 'immutable'
classNames = require 'classnames'

{div,span,table,tbody,td,tr,th,ul,li} = React.DOM

scalarTypes = Immutable.Set(['string','number','boolean'])
autoOpenKeys = Immutable.Set(['lookup','index','keypath'])

isScalar = (x) ->
  !x? or scalarTypes.has(typeof x)

isShortList = (x) ->
  (Immutable.Seq.isSeq(x) or Immutable.Set.isSet(x) or Immutable.List.isList(x)) and (x.size <= 1)

autoOpenKey = (key) ->
  autoOpenKeys.has(key)

autoOpenVal = (val) ->
  isScalar(val) or isShortList(val)

valueToElement = (val) ->
  if Immutable.Map.isMap(val)
    React.createElement MapEl, data: val
  else if Immutable.List.isList(val) or Immutable.Seq.isSeq(val)
    React.createElement ListEl, data: val
  else if Immutable.Set.isSet(val)
    React.createElement ListEl, data: val.valueSeq()
  else
    if val?
      val.toString()
    else
      "(null)"

ListEl = React.createClass
  displayName: 'ListEl'
  render: ->
    items = []
    @props.data.forEach (val,i) ->
      items.push li {key:"item-#{i}",className:'listItem'}, valueToElement(val)
    ul {className:classNames('list',@props.className)},
      items

MapEntryEl = React.createClass
  displayName: 'MapEntryEl'
  getInitialState: ->
    { folded: !autoOpenVal(@props.val) and !autoOpenKey(@props.keystr) }
  render: ->
    if @state.folded# and !autoOpenKey(@props.keystr) and !autoOpenVal(@props.value)
      tr {className:'mapEntry', key:@props.keystr },
        th {className:'mapKey', onClick: @toggleFold}, @props.keystr, "..."
        td {className:'mapValue'}, ""
    else
      tr {className:'mapEntry', key:@props.keystr, onClick: @clicked},
        th {className:'mapKey', onClick: @toggleFold}, @props.keystr
        td {className:'mapValue'}, valueToElement(@props.val)

  toggleFold: (e) ->
    @setState (s) -> { folded: !s.folded }
    e.preventDefault()

  
MapEl = React.createClass
  displayName: 'MapEl'

  render: ->
    rows = []
    @props.data.forEach (val,key) ->
      rows.push React.createElement MapEntryEl, key:key, keystr:key,val:val
    table {className:classNames('map',@props.className)},
      tbody {},
        rows


SystemLogUI = React.createClass
  displayName: 'SystemLogUI'

  render: ->
    if @props.systemLog?
      # s = ''
      # @props.systemLog.keySeq().forEach (k) -> s += "#{k},"
      # div {className: 'duder'}, "Systems: #{s}"
      React.createElement MapEl, className: 'systemLog', data: @props.systemLog

    else
      div {className: 'duder'}, "(Syslog not updated)"


module.exports = SystemLogUI
#
#
# MainTitleSystem:
#   search: [
#     { as 'main_title', lookup: { index: ['type'], keypath: ['main_title'] } }
#     { as 'controller', lookup: { index: ['eid','type'], keypath: [['main_title','eid'],'controller'] } }
#   ]
#   results:
#
#
#
#
#
#
#
#
#
#