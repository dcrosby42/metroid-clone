ViewSystem = require '../view_system'
C = require '../../components'
T = C.Types

class ViewportSyncSystem extends ViewSystem
  @Subscribe: [ T.Viewport, T.Position ]

  process: (r) ->
    [viewport,position] = r.comps
    layer = @uiState.getLayer('base')
    layer.x = -position.x
    layer.y = -position.y

module.exports = -> new ViewportSyncSystem()

