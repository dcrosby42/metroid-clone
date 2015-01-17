ArrayToCacheBinding = require '../../pixi_ext/array_to_cache_binding'
SoundController = require '../../pixi_ext/sound_controller'


class SoundSyncSystem
  constructor: ({@soundCache}) ->

  run: (estore, dt, input) ->
    sounds = estore.getComponentsOfType('sound')

    ArrayToCacheBinding.update
      source: sounds
      cache: @soundCache
      # identKey: 'eid'
      identFn: (comp) -> "#{comp.eid}-#{comp.soundId}"

      addFn: (soundComp) =>
        instance = SoundController.playSound soundComp.soundId
        instance.volume = soundComp.volume if soundComp.volume?
        if soundComp.loop
          instance.loop = -1
        instance

      removeFn: (instance) =>
        if instance?
          instance.stop()
        else
          console.log "SoundSyncSystem: ArrayToCacheBinding removeFn called with", instance
        
      syncFn: (soundComp,instance) =>
        # if soundComp.restart? and soundComp.restart
        # TODO: sound component could indicate a change in play state that should affect the instance

module.exports = SoundSyncSystem
