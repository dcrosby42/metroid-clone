ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
AnchoredBox = require '../../utils/anchored_box'
PIXI = require 'pixi.js'

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

updateSidecar = (gfx, hitBoxVisual) ->
  gfx._sidecar ||= {}
  gfx._sidecar.color = hitBoxVisual.get('color')
  gfx._sidecar.anchorColor = hitBoxVisual.get('anchorColor')
  gfx


module.exports =
  systemType: 'output'

  update: (entityFinder, input, ui) -> 

    res = if ui.drawHitBoxes
      entityFinder.search(['hit_box','hit_box_visual']).toArray()
    else
      []
      
    ArrayToCacheBinding.update
      source: res
      cache: ui.hitBoxVisualCache
      identFn: (x) -> x.getIn ['hit_box','eid']
      
      addFn: (comps) =>
        gfx = new PIXI.Graphics()
        hitBox = comps.get('hit_box')
        hitBoxVisual = comps.get('hit_box_visual')

        drawBoundingBox(gfx, hitBox, hitBoxVisual)
        
        container = ui.layers[hitBoxVisual.get('layer')] || ui.layers.default
        container.addChild gfx
        updateSidecar(gfx,hitBoxVisual)
        gfx

      removeFn: (gfx) =>
        gfx.parent.removeChild gfx

      syncFn: (comps,gfx) =>
        hitBox = comps.get('hit_box')
        hitBoxVisual = comps.get('hit_box_visual')
        gfx.position.set hitBox.get('x'), hitBox.get('y')

        if hitBoxVisual.get('color') != gfx._sidecar.color or hitBoxVisual.get('anchorColor') != gfx._sidecar.anchorColor
          gfx.clear()
          updateSidecar(gfx,hitBoxVisual)
