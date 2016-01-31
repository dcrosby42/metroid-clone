ViewObjectSyncSystem = require '../view_object_sync_system'

class SoundSyncSystem extends ViewObjectSyncSystem
  @Subscribe: ['sound']
  @SyncComponent: 'sound'

  newObject: (comps) ->
    soundComp = comps.get('sound')
    soundId = soundComp.get('soundId')

    sound = @ui.playSound(soundId)
    return null unless sound?

    sound.setVolume soundComp.get('volume')
    sound.setLooping soundComp.get('loop')
    sound.setResound soundComp.get('resound')
    sound

  updateObject: (comps,sound) ->
    # TODO: sound component could indicate a change in play state that should affect the instance

  removeObject: (sound) ->
    console.log "howler sound sync: removeObject",sound
    return unless sound?
    sound.remove()

module.exports = SoundSyncSystem
