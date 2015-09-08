ViewSystem = require '../view_system'

class MapSyncSystem extends ViewSystem
  @Subscribe: ['map']

  process: ->
    found = false
    @searchComponents().forEach (comps) =>
      found = true
      mapName = comps.getIn(['map','name'])
      @ui.setMap @config.getMapDatabase(), mapName

    if !found
      @ui.hideMaps()

module.exports = MapSyncSystem

