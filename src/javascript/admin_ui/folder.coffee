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
        span {className: 'folder-control open'}, "- "
      else
        span {className: 'folder-control closed'}, "+ "

    div {className: classnames('folder-container',@props.classNames)}, [
      div {className: 'folder-header',onClick:@headerClicked,key:'folderhead'}, folder, @props.title
      @props.deferredChildren() if @state.foldOpen
    ]

Folder.create = (props, deferredChildren) ->
  props.deferredChildren = deferredChildren
  React.createElement Folder, props

module.exports = Folder
