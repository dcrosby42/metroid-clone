ViewSystem = require '../view_system'

class ViewportSystem extends ViewSystem
  @Subscribe: [ 'viewport', 'position' ]

  process: ->
    @searchComponents().forEach (comps) =>
      # viewport = comps.get('viewport')
      position = comps.get('position')

      # layer = @ui.getLayer(viewport.get('layer'))
      layer = @ui.getLayer('base')
      layer.x = -position.get('x')
      layer.y = -position.get('y')

module.exports = ViewportSystem

