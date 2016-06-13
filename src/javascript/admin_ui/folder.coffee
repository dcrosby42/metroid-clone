React = require 'react'
{div,span,table,tbody,td,tr} = React.DOM
classnames = require 'classnames'

Folder = React.createClass
  displayName: 'Folder'
  getInitialState: ->
    {
      foldOpen: !!@props.startOpen
    }

  headerClicked: (e) ->
    e.preventDefault()
    @setState (prev) ->
      { foldOpen: !prev.foldOpen }

  render: ->
    folder = if @state.foldOpen
        span {className: 'folder-control open', key:"#{@props.folderkey}-fc"}, "- "
      else
        span {className: 'folder-control closed', key:"#{@props.folderkey}-fc"}, "+ "
    titleSpan = span {key:"#{@props.folderkey}-ts"}, @props.title

    div {className: classnames('folder-container',@props.classNames), key:"#{@props.folderkey}-fcon"}, [
      div {className: 'folder-header',onClick:@headerClicked, key: "#{@props.folderkey}-fh"}, folder, titleSpan
      @props.deferredChildren() if @state.foldOpen
    ]

Folder.create = (props, deferredChildren) ->
  props.deferredChildren = deferredChildren
  props.key=props.folderkey
  React.createElement Folder, props

module.exports = Folder
