ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
AnchoredBox = require '../../utils/anchored_box'
PIXI = require 'pixi.js'

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
        hitBox = estore.getComponent(hitBoxVisual.eid, 'hit_box')
        abox = new AnchoredBox(hitBox)
        abox.setXY 0,0

        thickness = 0.5
        color = hitBoxVisual.color || 0xFFFFFF
        pinColor = 0xFF0000
        
        gfx = new PIXI.Graphics()

        gfx.lineStyle thickness, color
        # gfx.drawRect -32,-16,64,32
        gfx.drawRect abox.left, abox.top, abox.width, abox.height

        gfx.lineStyle thickness, pinColor
        gfx.moveTo(0,4)
        gfx.lineTo(0,0)
        gfx.lineTo(4,0)

        @layer.addChild gfx
        gfx

      removeFn: (gfx) =>
        gfx.parent.removeChild gfx

      syncFn: (hitBoxVisual,gfx) =>
        hitBox = estore.getComponent(hitBoxVisual.eid, 'hit_box')
        gfx.position.set hitBox.x, hitBox.y


module.exports = HitBoxVisualSyncSystem

