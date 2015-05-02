module.exports =
  config:
    filters: [ 'sound' ]

  update: (comps, input, u) ->
    sound = comps.get('sound')
    newPlayPosition = sound.get('playPosition') + input.get('dt')
    if newPlayPosition > sound.get('timeLimit')
      if sound.get('loop')
        u.update sound.set('playPosition', 0)
      else
        u.delete sound
    else
      u.update sound.set('playPosition', newPlayPosition)
