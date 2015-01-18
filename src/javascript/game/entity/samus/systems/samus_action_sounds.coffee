# ObjectUtils = require '../../../../utils/object_utils'
Common = require '../../components'

class SamusActionSounds
  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      sound = estore.getComponent samus.eid, "sound"

      if samus.action == 'jump'
        sound = new Common.Sound
          soundId: 'jump'
          volume: 0.2
          playPosition: 0
          timeLimit: 170
        estore.addComponent samus.eid, sound
      # else if samus.action == 'run'
      #   sound = new Common.Sound
      #     soundId: 'step2'
      #     volume: 0.06
      #     playPosition: 0
      #     timeLimit: 20
      #     loop: true
      #   estore.addComponent samus.eid, sound
      #
      # else if samus.action == 'stop'
      #   sound = new Common.Sound
      #     soundId: 'step2'
      #     volume: 0.06
      #     playPosition: 0
      #     timeLimit: 20
      #     loop: false
      #   estore.addComponent samus.eid, sound
      
      if samus.motion == 'running'
        if !sound? or sound.soundId != 'step2'
          s = new Common.Sound
            soundId: 'step2'
            volume: 0.06
            playPosition: 0
            timeLimit: 20
            loop: true
          estore.addComponent samus.eid, s

      if sound? and sound.soundId == 'step2' and samus.motion != 'running'
        estore.removeComponent samus.eid, sound



module.exports = SamusActionSounds
