
class VisualTimerSystem
  run: (estore, dt, input) ->
    visuals = estore.getComponentsOfType('visual')
    for visual in visuals
      visual.time += dt

module.exports = VisualTimerSystem

