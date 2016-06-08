ViewObjectSyncSystem = require '../view_object_sync_system'
AnimatedSprite = require '../../pixi_ext/animated_sprite'
C = require '../../components'
T = C.Types

class AnimationSyncSystem extends ViewObjectSyncSystem
  @Subscribe: [ T.Animation, T.Position ]
  @SyncComponentInSlot: 0
  @CacheName: 'animation'

  newObject: (r) ->
    animation = r.comps[0]
    name = animation.spriteName
    layer = animation.layer

    config = @uiConfig.getSpriteConfig(name)
    if config?
      sprite = AnimatedSprite.create(config)
      sprite._name = "Animated Sprite - #{name}"
      sprite._sidecar =
        animation: null
        position: null
      layer ?= sprite.layer
      @uiState.addObjectToLayer sprite, layer
      return sprite
    else
      console.log "!! AnimationSyncSystem: No sprite config defined for '#{name}'"
      return null

  updateObject: (r,sprite) ->
    [animation,position] = r.comps
    prev = sprite._sidecar
    unless animation.equals(prev.animation)
      sprite.visible = animation.visible
      sprite.displayAnimation animation.state, animation.time
      prev.animation = animation.clone()

    unless position.equals(prev.position)
      sprite.position.set position.x, position.y
      prev.position = position.clone()

module.exports = -> new AnimationSyncSystem()
