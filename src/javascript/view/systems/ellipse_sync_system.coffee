PIXI = require 'pixi.js'
Immutable = require 'immutable'
ViewObjectSyncSystem = require "../view_object_sync_system"

class EllipseSyncSystem extends ViewObjectSyncSystem
  @Subscribe: ['ellipse', 'position']
  @SyncComponent: 'ellipse'

  newObject: (comps) ->
    ellipse = comps.get('ellipse')
    layer = ellipse.get('layer')
    position = comps.get('ellipse')

    gfx = new PIXI.Graphics()
    gfx._sidecar = {}

    @_draw(gfx,ellipse)
    @_move(gfx,position)

    @ui.addObjectToLayer(gfx, layer)

  updateObject: (comps, gfx) ->
    @_draw(gfx,comps.get('ellipse'))
    @_move(gfx,comps.get('position'))

  _draw: (gfx,ellipse) ->
    prev = gfx._sidecar
    return if Immutable.is(prev.ellipse, ellipse)

    gfx.clear()
    if ellipse.get('visible')
      lineColor = ellipse.get('lineColor')
      fillColor = ellipse.get('fillColor')
      if lineColor?
        lineWidth = ellipse.get('lineWidth',1)
        lineAlpha = ellipse.get('lineAlpha',1)
        gfx.lineStyle lineWidth, lineColor, lineAlpha
      if fillColor?
        fillAlpha = ellipse.get('fillAlpha',1)
        gfx.beginFill fillColor, fillAlpha
      gfx.drawEllipse(
        ellipse.get('x')
        ellipse.get('y')
        ellipse.get('width')
        ellipse.get('height')
      )
      gfx.endFill()

    prev.ellipse = ellipse
    null

  _move: (gfx,position) ->
    prev = gfx._sidecar
    return if Immutable.is(prev.position, position)
    gfx.position.set position.get('x'), position.get('y')
    prev.position = position
    null

module.exports = EllipseSyncSystem

