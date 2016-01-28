PIXI = require 'pixi.js'
Immutable = require 'immutable'
ViewObjectSyncSystem = require '../view_object_sync_system'
AnchoredBox = require '../../utils/anchored_box'

Defaults = {
  boxColor: 0x0f0f0f
  boxLineThickness: 1
  anchorColor: 0x0f0fff
  anchorLineThickness: 1
}

drawBoundingBox = (gfx,hitBox,hitBoxVisual) ->
  abox = new AnchoredBox(hitBox.toJS())
  abox.setXY 0,0

  color = hitBoxVisual.get('color') || Defaults.boxColor
  gfx.lineStyle Defaults.boxLineThickness, color
  gfx.drawRect abox.left, abox.top, abox.width, abox.height

  anchorColor = hitBoxVisual.get('anchorColor') || Defaults.anchorColor
  gfx.lineStyle Defaults.anchorLineThickness, anchorColor
  gfx.moveTo(0,4)
  gfx.lineTo(0,0)
  gfx.lineTo(4,0)
  gfx

updateSidecar = (gfx, hitBox, hitBoxVisual) ->
  gfx._sidecar ||= {}
  gfx._sidecar.color = hitBoxVisual.get('color')
  gfx._sidecar.anchorColor = hitBoxVisual.get('anchorColor')
  gfx._sidecar.height = hitBox.get('height')
  gfx

class HitBoxVisualSyncSystem extends ViewObjectSyncSystem
  @Subscribe: ['hit_box','hit_box_visual']
  @SyncComponent: 'hit_box'

  # Override search to return empty if ui.drawHitboxes is false:
  searchComponents: ->
    if @ui.drawHitBoxes then super() else Immutable.List()


  newObject: (comps) ->
    gfx = new PIXI.Graphics()
    hitBox = comps.get('hit_box')
    hitBoxVisual = comps.get('hit_box_visual')

    drawBoundingBox(gfx, hitBox, hitBoxVisual)
    updateSidecar(gfx, hitBox, hitBoxVisual)
    
    @ui.addObjectToLayer(gfx, hitBoxVisual.get('layer'))
    gfx

  updateObject: (comps,gfx) ->
    hitBox = comps.get('hit_box')
    hitBoxVisual = comps.get('hit_box_visual')
    gfx.position.set hitBox.get('x'), hitBox.get('y')

    if hitBoxVisual.get('color') != gfx._sidecar.color or hitBoxVisual.get('anchorColor') != gfx._sidecar.anchorColor or hitBox.get('height') != gfx._sidecar.height
      console.log "hitboxvisualsyncsystem: clear"
      gfx.clear()
      drawBoundingBox(gfx, hitBox, hitBoxVisual)
      updateSidecar(gfx, hitBox, hitBoxVisual)

module.exports = HitBoxVisualSyncSystem

