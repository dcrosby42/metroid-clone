
module.exports =
  systemType: 'output'

  update: (entityFinder, input, ui) ->

    entityFinder.search(['map']).forEach (comps) ->
      mapName = comps.getIn(['map','name'])
      if ui.currentMapName != mapName
        # Set the currently showing map in the UI:
        ui.currentMapName = mapName
        _.forEach _.keys(ui.layers.maps), (name) ->
            container = ui.layers.maps[name]
            container.visible = (name == ui.currentMapName)
