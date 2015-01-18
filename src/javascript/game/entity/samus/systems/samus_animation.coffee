ObjectUtils = require '../../../../utils/object_utils'

class SamusAnimation
  constructor: ->
    defs = [
      [['standing','right','straight','no'], 'stand-right']
      [['standing','right','up','no'],       'stand-right-aim-up']
      [['standing','left','straight','no'],  'stand-left']
      [['standing','left','up','no'],        'stand-left-aim-up']

      [['standing','right','straight','shoot'], 'stand-right-shoot']
      [['standing','right','up','shoot'],       'stand-right-aim-up']
      [['standing','left','straight','shoot'],  'stand-left-shoot']
      [['standing','left','up','shoot'],        'stand-left-aim-up']


      [['running','left','straight','no'],   'run-left']
      [['running','left','up','no'],         'run-left-aim-up']
      [['running','right','straight','no'],  'run-right']
      [['running','right','up','no'],        'run-right-aim-up']

      [['running','left','straight','shoot'],   'run-left']
      [['running','left','up','shoot'],         'run-left-aim-up']
      [['running','right','straight','shoot'],  'run-right']
      [['running','right','up','shoot'],        'run-right-aim-up']


      [['jumping','right','up','no'],        'jump-right']
      [['jumping','right','straight','no'],  'jump-right']
      [['jumping','left','up','no'],         'jump-left']
      [['jumping','left','straight','no'],   'jump-left']

      [['jumping','right','up','shoot'],        'jump-right']
      [['jumping','right','straight','shoot'],  'jump-right']
      [['jumping','left','up','shoot'],         'jump-left']
      [['jumping','left','straight','shoot'],   'jump-left']


      [['falling','right','up','no'],        'jump-right']
      [['falling','right','straight','no'],  'jump-right']
      [['falling','left','up','no'],         'jump-left']
      [['falling','left','straight','no'],   'jump-left']

      [['falling','right','up','shoot'],        'jump-right']
      [['falling','right','straight','shoot'],  'jump-right']
      [['falling','left','up','shoot'],         'jump-left']
      [['falling','left','straight','shoot'],   'jump-left']
    ]
    @states = {}
    _.forEach defs, ([path,state]) =>
      ObjectUtils.setDeep @states, path, state


  run: (estore, dt, input) ->
    for samus in estore.getComponentsOfType('samus')
      visual = estore.getComponent(samus.eid, 'visual')
      oldState = visual.state

      keyPath = ObjectUtils.getPropertiesList samus, ['motion','direction','aim','recoil']
      visual.state = ObjectUtils.getDeep @states, keyPath

      if visual.state != oldState
        visual.time = 0
      else
        visual.time += dt

module.exports = SamusAnimation
