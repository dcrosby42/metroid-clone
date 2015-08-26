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


filters = FilterExpander.expandFilterGroups([ 'animation', 'position' ])

module.exports =
  systemType: 'output'

  update: (entityFinder, ui) ->

    vps = entityFinder.search(filters)

    ArrayToCacheBinding.update
      source: vps.toArray()
      cache: ui.spriteCache
      identFn: (vp) -> vp.getIn ['animation','cid']

      addFn: (vp) =>
        newAnimatedSprite ui, vp.getIn ['animation','spriteName']

      removeFn: (sprite) =>
        removeSprite(sprite)

      syncFn: (vp,sprite) =>
        animation = vp.get('animation')
        position = vp.get('position')
        sprite.visible = animation.get('visible')
        sprite.displayAnimation animation.get('state'), animation.get('time')
        sprite.position.set position.get('x'), position.get('y')

