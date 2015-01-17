# ObjectUtils = require '../../../../utils/object_utils'
Common = require '../../components'

class SamusActionSounds
  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      if samus.action == 'jump'
        sound = new Common.Sound
          soundId: 'jump'
          volume: 0.2
          playPosition: 0
          timeLimit: 170 
        estore.addComponent samus.eid, sound

module.exports = SamusActionSounds
