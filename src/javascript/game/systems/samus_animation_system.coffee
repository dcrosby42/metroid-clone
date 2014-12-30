ObjectUtils = require '../../utils/object_utils'

class SamusAnimationSystem
  constructor: ->
    defs = [
      [['standing','right','straight'], 'stand-right']
      [['standing','right','up'],       'stand-right-aim-up']
      [['standing','left','straight'],  'stand-left']
      [['standing','left','up'],        'stand-left-aim-up']

      [['running','left','straight'],   'run-left']
      [['running','left','up'],         'run-left-aim-up']
      [['running','right','straight'],  'run-right']
      [['running','right','up'],        'run-right-aim-up']

      [['jumping','right','up'],        'jump-right']
      [['jumping','right','straight'],  'jump-right']
      [['jumping','left','up'],         'jump-left']
      [['jumping','left','straight'],   'jump-left']

      [['falling','right','up'],        'jump-right']
      [['falling','right','straight'],  'jump-right']
      [['falling','left','up'],         'jump-left']
      [['falling','left','straight'],   'jump-left']
    ]
    @states = {}
    _.forEach defs, ([path,state]) =>
      ObjectUtils.setDeep @states, path, state


  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      visual = estore.getComponent(samus.eid, 'visual')
      oldState = visual.state

      keyPath = ObjectUtils.getPropertiesList samus, ['action','direction','aim']
      visual.state = ObjectUtils.getDeep @states, keyPath

      if visual.state != oldState
        visual.time = 0
      else
        visual.time += dt

module.exports = SamusAnimationSystem
