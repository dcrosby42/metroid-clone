ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
AnchoredBox = require '../../utils/anchored_box'
PIXI = require 'pixi.js'

createBoundingBoxGraphics = (estore,hitBoxVisual) ->
  gfx
  

drawBoundingBox = (gfx,estore,hitBoxVisual) ->
  hitBox = estore.getComponent(hitBoxVisual.eid, 'hit_box')
  abox = new AnchoredBox(hitBox)
  abox.setXY 0,0

  thickness = 1
  color = hitBoxVisual.color || 0x0f0f0f
  pinColor = hitBoxVisual.anchorColor || 0x0f0fff
  

  gfx.lineStyle thickness, color
  # gfx.drawRect -32,-16,64,32
  gfx.drawRect abox.left, abox.top, abox.width, abox.height

  gfx.lineStyle thickness, pinColor
  gfx.moveTo(0,4)
  gfx.lineTo(0,0)
  gfx.lineTo(4,0)
  gfx

updateSidecar = (gfx, hitBoxVisual) ->
  gfx._sidecar ||= {}
  gfx._sidecar.color = hitBoxVisual.color
  gfx._sidecar.anchorColor = hitBoxVisual.anchorColor
  gfx

removeFromParent = (gfx) ->
  gfx.parent.removeChild gfx

class HitBoxVisualSyncSystem
  constructor: ({@cache,@layer,@toggle}) ->
    @toggle ||= {value:true}

  run: (estore,dt,input) ->
    hitBoxVisuals = if @toggle.value
      estore.getComponentsOfType('hit_box_visual')
    else
      []

    ArrayToCacheBinding.update
      source: hitBoxVisuals
      cache: @cache
      identKey: 'eid'
      addFn: (hitBoxVisual) =>
        gfx = new PIXI.Graphics()
        drawBoundingBox(gfx, estore, hitBoxVisual)
        @layer.addChild gfx
        updateSidecar(gfx,hitBoxVisual)
        gfx

      removeFn: (gfx) =>
        removeFromParent(gfx)

      syncFn: (hitBoxVisual,gfx) =>
        hitBox = estore.getComponent(hitBoxVisual.eid, 'hit_box')
        gfx.position.set hitBox.x, hitBox.y

        if hitBoxVisual.color != gfx._sidecar.color or hitBoxVisual.anchorColor != gfx._sidecar.anchorColor
          gfx.clear()
          drawBoundingBox(gfx,estore,hitBoxVisual)
          updateSidecar(gfx,hitBoxVisual)


module.exports = HitBoxVisualSyncSystem

