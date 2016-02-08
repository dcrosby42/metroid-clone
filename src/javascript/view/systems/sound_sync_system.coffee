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
    # Attempt to keep playing sounds from "getting away from game state if we adminify
    # the timeline, pause, go back, etc
    # soundComp = comps.get('sound')
    # assumedPos = soundComp.get('playPosition')
    # actualPos = sound.playPositionMillis()
    # diff = assumedPos - actualPos
    # diff2 = null
    # if soundComp.get('loop')
    #   diff2 = diff + soundComp.get('timeLimit')
    # if diff < -18 and (!diff2 or (diff2? and diff2 > 18))
    #   sound.seekMillis(assumedPos)
    #   sound.pause()
    # else if diff > 18
    #   sound.seekMillis(assumedPos)
    #   sound.play()

  removeObject: (sound) ->
    if !sound?
      console.log "sound sync: removeObject called with null sound?"
      return
    sound.remove()


module.exports = SoundSyncSystem
