
# class VisualTimerSystem
#   run: (estore, dt, input) ->
#     visuals = estore.getComponentsOfType('visual')
#     for visual in visuals
#       visual.time += dt
#
# module.exports = VisualTimerSystem


module.exports
  config:
    components: [
      { match: { type: 'visual' } }
    ]

  update: ([visual], dt) ->
    visual.update 'time', (t) -> t + dt
