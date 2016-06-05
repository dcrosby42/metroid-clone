Immutable = require 'immutable'
ViewObjectSyncSystem = require '../view_object_sync_system'

AnimatedSprite = require '../../pixi_ext/animated_sprite'

class AnimationSyncSystem extends ViewObjectSyncSystem
  @Subscribe: [ 'animation', 'position' ]
  @SyncComponent: 'animation'

  newObject: (comps) ->
    animation = comps.get('animation')
    name = animation.get('spriteName')
    layer = animation.get('layer')
    # name = comps.getIn(['animation','spriteName'])
    config = @config.getSpriteConfig(name)
    if config?
      sprite = AnimatedSprite.create(config)
      sprite._name = "Animated Sprite - #{name}"
      sprite._sidecar =
        animation: null
        position: null
      layer ?= sprite.layer
      @ui.addObjectToLayer sprite, layer
      return sprite
    else
      console.log "!! AnimationSyncSystem: No sprite config defined for '#{name}'"
      return null

  updateObject: (comps,sprite) ->
    prev = sprite._sidecar
    animation = comps.get('animation')
    unless Immutable.is(animation, prev.animation)
      sprite.visible = animation.get('visible')
      sprite.displayAnimation animation.get('state'), animation.get('time')
      prev.animation = animation

    position = comps.get('position')
    unless Immutable.is(position, prev.position)
      sprite.position.set position.get('x'), position.get('y')
      prev.position = position

module.exports = AnimationSyncSystem
