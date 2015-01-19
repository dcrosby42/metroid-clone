class SkreeAnimation
  run: (estore, dt, input) ->
    for skree in estore.getComponentsOfType('skree')
      visual = estore.getComponent(skree.eid, 'visual')
      oldState = visual.state

      if skree.action == 'sleep'
        visual.state = 'wait'
      else
        visual.state = 'attack'

      if visual.state != oldState
        visual.time = 0

module.exports = SkreeAnimation
