Common = require '../../components'
BaseSystem = require '../../../../ecs/base_system'

class SamusActionSoundsSystem extends BaseSystem
  @Subscribe: [ 'samus' ]

  process: ->
    samus = @getComp('samus')
    # eid = samus.get('eid')
    # sound = comps.get('sound')
    sound = @getEntityComponent(@eid(),'sound')

    if samus.get('action') == 'jump'
      sound = Common.Sound.merge
        soundId: 'jump'
        volume: 0.2
        playPosition: 0
        timeLimit: 170
      @addComp sound

    if samus.get('motion') == 'running'
      if !sound? or sound.get('soundId') != 'step2'
        s = Common.Sound.merge
          soundId: 'step2'
          volume: 0.04
          playPosition: 0
          timeLimit: 20
          loop: true
        @addComp s

    if sound? and sound.get('soundId') == 'step2' and samus.get('motion') != 'running'
      @deleteComp sound

module.exports = SamusActionSoundsSystem

