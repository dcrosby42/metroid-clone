class SoundSystem
  run: (estore, dt, input) ->
    sounds = estore.getComponentsOfType('sound')
    for sound in sounds
      sound.playPosition += dt
      if sound.playPosition >= sound.timeLimit
        estore.removeComponent sound.eid, sound

module.exports = SoundSystem

