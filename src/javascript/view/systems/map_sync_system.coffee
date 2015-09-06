ViewSystem = require '../view_system'

class MapSyncSystem extends ViewSystem
  @Subscribe: ['map']

  process: ->
    found = false
    @searchComponents().forEach (comps) =>
      found = true
      @ui.setMap comps.getIn(['map','name'])

    if !found
      @ui.hideMaps()

module.exports = MapSyncSystem

