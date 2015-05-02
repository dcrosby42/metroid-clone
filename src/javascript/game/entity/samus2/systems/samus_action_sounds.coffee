Common = require '../../components2'

module.exports =
  config:
    filters: ['samus']

  update: (comps,input,u) ->
    samus = comps.get('samus')
    eid = samus.get('eid')
    # sound = comps.get('sound')
    sound = u.getEntityComponent(eid,'sound')

    if samus.get('action') == 'jump'
      sound = Common.Sound.merge
        soundId: 'jump'
        volume: 0.2
        playPosition: 0
        timeLimit: 170
      u.add eid, sound

    if samus.get('motion') == 'running'
      if !sound? or sound.get('soundId') != 'step2'
        s = Common.Sound.merge
          soundId: 'step2'
          volume: 0.04
          playPosition: 0
          timeLimit: 20
          loop: true
        u.add eid, s

    if sound? and sound.get('soundId') == 'step2' and samus.get('motion') != 'running'
      u.delete sound


