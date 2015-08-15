
FilterExpander = require '../../ecs/filter_expander'
filters = FilterExpander.expandFilterGroups([ 'map' ])

module.exports =
  systemType: 'output'

  update: (entityFinder, ui) ->
    entityFinder.search(filters).forEach (comps) ->
      ui.setMap comps.getIn(['map','name'])
