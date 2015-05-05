module.exports =
  config:
    filters:
      ['skree','visual']

  update: (comps,input,u) ->
    skree = comps.get('skree')
    visual = comps.get('visual')

    state = if skree.get('action') == 'sleep'
      'wait'
    else
      'attack'

    visual = if state != visual.get('state')
      visual.set('time',0)
    else
      visual

    u.update visual.set('state',state)


