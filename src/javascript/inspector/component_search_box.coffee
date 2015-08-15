React = require 'react'
Immutable = require 'immutable'
List = Immutable.List
Map = Immutable.Map

FilterExpander = require '../ecs/filter_expander'

ComponentSearchBox = React.createClass
  displayName: 'ComponentSearchBox'
  getInitialState: ->
    {
      queryString: '["samus"]'
      # searchResults: Immutable.fromJS([ { cid: 'c1', eid: 'e9', type: 'samus', action: 'runLeft', jump: false } ]).toString()
      expandedFilters: List()
      searchResults: List() #Immutable.fromJS([ { cid: 'c1', eid: 'e9', type: 'samus', action: 'runLeft', jump: false } ]).toString()
    }

  handleChange: (e) ->
    @setState { queryString: e.target.value }

  searchClicked: (e) ->
    filters = Immutable.fromJS(JSON.parse(@state.queryString))
    @state.expandedFilters = FilterExpander.expandFilterGroups(filters)
    console.log "ComponentSearchBox: expanded filters: ",@state.expandedFilters.toJS()
    if @props.entityStore?
      @state.searchResults = @props.entityStore.search @state.expandedFilters
      console.log "ComponentSearchBox: search results: ",@state.searchResults.toJS()
    else
      console.log "ComponentSearchBox: no estore to search!"
      


  render: ->
    React.DOM.div {className: 'component-search-box'},
      "Component search box"
      React.createElement 'input', {className: 'query', value: @state.queryString, onChange: @handleChange}
      React.createElement 'button', {type: 'button', className: 'search-button', onClick: @searchClicked},
        "Search"
      React.createElement 'pre', {className: 'searchResults'},
        @state.expandedFilters.toString()
      React.createElement 'pre', {className: 'searchResults'},
        @state.searchResults.toString()

      # React.createElement 'textarea', {defaultValue: @state.queryString, className: 'query', onChange: @handleChange}

module.exports = ComponentSearchBox

