ViewObjectSyncSystem = require '../view_object_sync_system'
C = require '../../components'
T = C.Types

class SoundSyncSystem extends ViewObjectSyncSystem
  @Subscribe: [T.Sound]
  @SyncComponentInSlot: 0
  @CacheName: 'sound'

  newObject: (r) ->
    soundComp = r.comps[0]
    soundId = soundComp.soundId

    sound = @uiState.playSound(soundId)
    return null unless sound?

    sound.setVolume soundComp.volume
    sound.setLooping soundComp.loop
    sound.setResound soundComp.resound
    sound._sidecar =
      playPosition: soundComp.playPosition

    sound

  updateObject: (r,sound) ->
    # Attempt to keep playing sounds from "getting away from game state" if we pass, step back or forward.
    soundComp = r.comps[0]
    playPosition = soundComp.playPosition
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


module.exports = -> new SoundSyncSystem()
