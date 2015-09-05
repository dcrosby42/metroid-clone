ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
# AnimatedSprite = require '../../pixi_ext/animated_sprite'
PIXI = require 'pixi.js'

FilterExpander = require '../../ecs/filter_expander'

Defaults =
  font: "normal 10pt Arial"
  fillColor: "white"

newLabel = (ui, labelComp) ->
  textContent = labelComp.get('content')
  style =
    font: labelComp.get('font', Defaults.font)
    fill: labelComp.get('fill_color', Defaults.fillColor)

  console.log style
  label = new PIXI.Text(textContent, style)
  container = ui.layers[labelComp.get('layer')] || ui.layers.overlay || ui.layers.default
  container.addChild label


# TODO: Refactor/reuse: this is the same code for removing any Pixi display object.
removeDisplayObject = (x) ->
  x.parent.removeChild x


filters = FilterExpander.expandFilterGroups([ 'label', 'position' ])

module.exports =
  systemType: 'output'

  update: (entityFinder, ui) ->

    res = entityFinder.search(filters)

    ArrayToCacheBinding.update
      source: res.toArray()
      cache: ui.labelCache
      identFn: (comps) -> comps.getIn ['label','cid']

      addFn: (comps) =>
        newLabel ui, comps.get('label')

      removeFn: (label) =>
        removeDisplayObject(label)

      syncFn: (comps,label) =>
        labelComp = comps.get('label')
        position = comps.get('position')
        content = labelComp.get('content')
        x = position.get('x')
        y = position.get('y')

        if x != label.position.x or y != label.position.y
          label.position.set x,y

        if content != label.text
          label.setText(content)

        label.visible = labelComp.get('visible')

