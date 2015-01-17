ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
# AnimatedSprite = require '../../pixi_ext/animated_sprite'

class SoundSyncSystem
  constructor: ({@soundCache}) ->

  run: (estore, dt, input) ->
    sounds = estore.getComponentsOfType('sound')

    ArrayToCacheBinding.update
      source: sounds
      cache: @soundCache
      identKey: 'eid'

      addFn: (sound) =>
        instance = createjs.Sound.play(sound.soundId)
        instance.volume = sound.volume if sound.volume?
        instance

      removeFn: (instance) =>
        if instance?
          instance.stop()
        else
          console.log "SoundSyncSystem: ArrayToCacheBinding removeFn called with", instance
        
      syncFn: (sound,instance) =>
        # TODO: sound component could indicate a change in play state that should affect the instance

module.exports = SoundSyncSystem
