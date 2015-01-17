class SoundSystem
  run: (estore, dt, input) ->
    sounds = estore.getComponentsOfType('sound')
    for sound in sounds
      sound.playPosition += dt
      if sound.playPosition >= sound.timeLimit
        if sound.loop
          sound.playPosition = 0
          # sound.restart = true
        else
          estore.removeComponent sound.eid, sound
      # else
        # sound.restart = false

module.exports = SoundSystem

