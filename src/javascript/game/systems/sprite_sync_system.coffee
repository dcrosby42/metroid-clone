ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
AnimatedSprite = require '../../pixi_ext/animated_sprite'

newAnimatedSprite = (ui, name) ->
  config = ui.spriteConfigs[name]
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

module.exports =
  systemType: 'output'

  update: (entityFinder, input, ui) ->

    vps = entityFinder.search(['visual','position'])

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
        sprite.displayAnimation visual.get('state'), visual.get('time')
        sprite.position.set position.get('x'), position.get('y')

