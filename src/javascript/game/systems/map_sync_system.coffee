
FilterExpander = require '../../ecs/filter_expander'
filters = FilterExpander.expandFilterGroups([ 'map' ])

module.exports =
  systemType: 'output'

  update: (entityFinder, ui) ->

    entityFinder.search(filters).forEach (comps) ->
      mapName = comps.getIn(['map','name'])
      if ui.currentMapName != mapName
        # Set the currently showing map in the UI:
        ui.currentMapName = mapName
        _.forEach _.keys(ui.layers.maps), (name) ->
            container = ui.layers.maps[name]
            container.visible = (name == ui.currentMapName)
