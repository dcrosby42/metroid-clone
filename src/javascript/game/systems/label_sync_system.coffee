ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
# AnimatedSprite = require '../../pixi_ext/animated_sprite'
PIXI = require 'pixi.js'

FilterExpander = require '../../ecs/filter_expander'

newLabel = (ui, labelComp) ->
  textContent = labelComp.get('content')
  style =
    fill: 'white'
    # font: "normal 10pt narpassword00000_regular_20"
    # font: "narpassword00000_regular_20"
    font: "regular 10pt Arial"

  label = new PIXI.Text(textContent, style)
  container = ui.layers.overlay || ui.layers.default
  container.addChild label
    # container.addChild sprite
  # config = ui.getSpriteConfig(name)
  # if config?
    # sprite = AnimatedSprite.create(config)
    # container = ui.layers[sprite.layer] || ui.layers.default
    # container.addChild sprite
    # sprite
  # else
  #   console.log "No sprite config defined for '#{name}'"

removeSprite = (sprite) ->
  container = sprite.parent
  container.removeChild sprite


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
        removeSprite(label)

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

