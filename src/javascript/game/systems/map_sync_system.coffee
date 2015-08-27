
FilterExpander = require '../../ecs/filter_expander'
filters = FilterExpander.expandFilterGroups([ 'map' ])

module.exports =
  systemType: 'output'

  update: (entityFinder, ui) ->
    found = false
    entityFinder.search(filters).forEach (comps) ->
      found = true
      ui.setMap comps.getIn(['map','name'])

    if !found
      ui.hideMaps()
