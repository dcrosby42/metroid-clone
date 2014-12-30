ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
AnimatedSprite = require '../../pixi_ext/animated_sprite'

class SpriteSyncSystem
  constructor: ({@spriteConfigs, @spriteLookupTable, @layers}) ->

  run: (estore, dt, input) ->
    visuals = estore.getComponentsOfType('visual')
    ArrayToCacheBinding.update
      source: visuals
      cache: @spriteLookupTable
      identKey: 'eid'
      addFn: (visual) =>
        config = @spriteConfigs[visual.spriteName]
        sprite = AnimatedSprite.create(config)
        container = @layers[sprite.layer] || @layers.default
        container.addChild sprite
        sprite
      removeFn: (sprite) =>
        @container.removeChild sprite
      syncFn: (visual,sprite) =>
        pos = estore.getComponent(visual.eid, 'position')
        sprite.displayAnimation visual.state, visual.time
        sprite.position.set pos.x, pos.y

module.exports = SpriteSyncSystem
