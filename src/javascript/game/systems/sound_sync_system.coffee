ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
SoundController = require '../../pixi_ext/sound_controller'


module.exports =
  systemType: 'output'

  update: (entityFinder, input, ui) ->
    sounds = entityFinder.search(['sound']).map (x) -> x.get('sound')

    ArrayToCacheBinding.update
      source: sounds.toArray()
      cache: ui.soundCache
      identFn: (s) -> s.get('cid')

      addFn: (sound) =>
        soundId = sound.get('soundId')
        volume = sound.get('volume')

        instance = SoundController.playSound(soundId)
        instance.volume = volume if volume?
        if sound.get('loop')
          instance.loop = -1

        if sound.get('resound')
          instance._resound = true
        else
          instance._resound = false

        instance

      removeFn: (instance) =>
        instance.stop() unless instance._resound
        
      syncFn: (soundComp,instance) =>
        # TODO: sound component could indicate a change in play state that should affect the instance
