module.exports =
  config:
    filters:
      ['skree','visual','enemy']

  update: (comps,input,u) ->
    skree = comps.get('skree')
    visual = comps.get('visual')
    enemy = comps.get('enemy')

    state = if skree.get('action') == 'sleep'
      'wait'
    else
      'attack'

    visual = visual.set('paused',false)
    stunned = enemy.get('stunned')
    if stunned? and stunned > 0
      u.update visual.set('state',"stunned-#{state}").set('paused',true)
      u.update enemy.set('stunned', stunned - input.get('dt'))
        # visual = comps.get('enemy-visual') #XXX
        # u.update visual.set('paused',true) #XXX

    else
      visual = if state != visual.get('state')
        visual.set('time',0)
      else
        visual

      u.update visual.set('state',state)


