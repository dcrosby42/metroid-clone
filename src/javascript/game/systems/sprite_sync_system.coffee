ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
AnimatedSprite = require '../../pixi_ext/animated_sprite'

FilterExpander = require '../../ecs/filter_expander'

newAnimatedSprite = (ui, name) ->
  config = ui.getSpriteConfig(name)
  if config?
    sprite = AnimatedSprite.create(config)
    container = ui.layers[sprite.layer] || ui.layers.default
    container.addChild sprite
    sprite
  else
    console.log "No sprite config defined for '#{name}'"

removeSprite = (sprite) ->
  container = sprite.parent
  container.removeChild sprite


filters = FilterExpander.expandFilterGroups([ 'visual', 'position' ])

module.exports =
  systemType: 'output'

  update: (entityFinder, ui) ->

    vps = entityFinder.search(filters)

    ArrayToCacheBinding.update
      source: vps.toArray()
      cache: ui.spriteCache
      identFn: (vp) -> vp.getIn ['visual','cid']

      addFn: (vp) =>
        newAnimatedSprite ui, vp.getIn ['visual','spriteName']

      removeFn: (sprite) =>
        removeSprite(sprite)

      syncFn: (vp,sprite) =>
        visual = vp.get('visual')
        position = vp.get('position')
        sprite.visible = visual.get('visible')
        sprite.displayAnimation visual.get('state'), visual.get('time')
        sprite.position.set position.get('x'), position.get('y')

