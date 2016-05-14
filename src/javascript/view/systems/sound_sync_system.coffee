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
    sound._sidecar =
      playPosition: soundComp.get('playPosition')

    sound

  updateObject: (comps,sound) ->
    # Attempt to keep playing sounds from "getting away from game state" if we pass, step back or forward.
    soundComp = comps.get('sound')
    playPosition = soundComp.get('playPosition')
    if sound._sidecar.paused
      if playPosition > sound._sidecar.playPosition
        sound.seekMillis(playPosition)
        sound.play()
        sound._sidecar.paused = false
        # console.log "sound_sync_system: seek/play"

    else
      if playPosition > 0 && playPosition == sound._sidecar.playPosition
        sound.pause()
        sound._sidecar.paused = true
        # console.log "sound_sync_system: pause",playPosition, sound._sidecar.playPosition
      else
        sound._sidecar.playPosition = playPosition

    
  removeObject: (sound) ->
    if !sound?
      console.log "sound sync: removeObject called with null sound?"
      return
    sound.remove()


module.exports = SoundSyncSystem
