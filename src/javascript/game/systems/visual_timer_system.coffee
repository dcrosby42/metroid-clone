module.exports =
  config:
    filters: [ 'visual' ]

  update: (comps, input, u) ->
    visual = comps.get('visual')
    u.update visual.update('time', (t) -> t + input.get('dt'))
