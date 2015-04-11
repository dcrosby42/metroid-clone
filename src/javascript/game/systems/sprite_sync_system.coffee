ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
AnimatedSprite = require '../../pixi_ext/animated_sprite'

newAnimatedSprite = (ui, name) ->
  config = ui.spriteConfigs[name]
  sprite = AnimatedSprite.create(config)
  container = ui.layers[sprite.layer] || ui.layers.default
  container.addChild sprite
  sprite

removeSprite = (sprite) ->
  container = sprite.parent
  container.removeChild sprite

module.exports =
  #TODO type: 'something'
  #TODO config: 'something'
  update: (entityFinder, ui, input) ->

    vps = entityFinder.search(['visual','position'])

    ArrayToCacheBinding.update
      source: vps
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

