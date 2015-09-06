PIXI = require 'pixi.js'
Immutable = require 'immutable'
ViewObjectSyncSystem = require "../view_object_sync_system"

class RectangleSyncSystem extends ViewObjectSyncSystem
  @Subscribe: ['rectangle', 'position']
  @SyncComponent: 'rectangle'

  newObject: (comps) ->
    rectangle = comps.get('rectangle')
    layer = rectangle.get('layer')
    position = comps.get('ellipse')

    gfx = new PIXI.Graphics()
    gfx._sidecar = {}

    @_draw(gfx,rectangle)
    @_move(gfx,position)

    @ui.addObjectToLayer(gfx, layer)

  updateObject: (comps, gfx) ->
    @_draw(gfx,comps.get('rectangle'))
    @_move(gfx,comps.get('position'))

  _draw: (gfx,rectangle) ->
    prev = gfx._sidecar
    return if Immutable.is(prev.rectangle, rectangle)

    gfx.clear()
    # gfx.lineStyle 1, 0xffffff, 1
    # gfx.drawRect(
    #   rectangle.get('x')
    #   rectangle.get('y')
    #   rectangle.get('width')
    #   rectangle.get('height')
    # )
    if rectangle.get('visible')
      lineColor = rectangle.get('lineColor')
      fillColor = rectangle.get('fillColor')
      if lineColor?
        lineWidth = rectangle.get('lineWidth',1)
        lineAlpha = rectangle.get('lineAlpha',1)
        gfx.lineStyle lineWidth, lineColor, lineAlpha
      if fillColor?
        fillAlpha = rectangle.get('fillAlpha',1)
        gfx.beginFill fillColor, fillAlpha
      gfx.drawRect(
        rectangle.get('x')
        rectangle.get('y')
        rectangle.get('width')
        rectangle.get('height')
      )
      gfx.endFill()

    prev.rectangle = rectangle
    null

  _move: (gfx,position) ->
    prev = gfx._sidecar
    return if Immutable.is(prev.position, position)
    gfx.position.set position.get('x'), position.get('y')
    prev.position = position
    null

module.exports = RectangleSyncSystem

