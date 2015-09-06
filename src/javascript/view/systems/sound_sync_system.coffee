ViewObjectSyncSystem = require '../view_object_sync_system'
SoundController = require '../../pixi_ext/sound_controller'


class SoundSyncSystem extends ViewObjectSyncSystem
  @Subscribe: ['sound']
  @SyncComponent: 'sound'

  newObject: (comps) ->
    soundComp = comps.get('sound')
    soundId = sound.get('soundId')
    volume = sound.get('volume')

    soundInstance = SoundController.playSound(soundId)
    soundInstance.volume = volume if volume?
    if soundComp.get('loop')
      soundInstance.loop = -1

    if soundComp.get('resound')
      soundInstance._resound = true
    else
      soundInstance._resound = false

    soundInstance

  updateObject: (comps,soundInstance) ->
    # TODO: sound component could indicate a change in play state that should affect the instance

  removeObject: (soundInstance) ->
    soundInstance.stop() unless soundInstance._resound

module.exports = SoundSyncSystem
