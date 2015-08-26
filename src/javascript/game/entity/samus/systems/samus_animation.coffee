BaseSystem = require '../../../../ecs/base_system'

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


  [['jumping','right','straight','no'],  'jump-right']
  [['jumping','right','up','no'],        'jump-right-aim-up']
  [['jumping','left','straight','no'],   'jump-left']
  [['jumping','left','up','no'],         'jump-left-aim-up']

  [['jumping','right','straight','shoot'],  'jump-right']
  [['jumping','right','up','shoot'],        'jump-right-aim-up']
  [['jumping','left','straight','shoot'],   'jump-left']
  [['jumping','left','up','shoot'],         'jump-left-aim-up']


  [['falling','right','straight','no'],  'jump-right']
  [['falling','right','up','no'],        'jump-right-aim-up']
  [['falling','left','straight','no'],   'jump-left']
  [['falling','left','up','no'],         'jump-left-aim-up']

  [['falling','right','straight','shoot'],  'jump-right']
  [['falling','right','up','shoot'],        'jump-right-aim-up']
  [['falling','left','straight','shoot'],   'jump-left']
  [['falling','left','up','shoot'],         'jump-left-aim-up']
]

ObjectUtils = require '../../../../utils/object_utils'
_ = require 'lodash'

states = {}
_.forEach defs, ([path,state]) =>
  ObjectUtils.setDeep states, path, state


class SamusAnimationSystem extends BaseSystem
  @Subscribe: [ 'samus', 'animation' ]

  process: ->
    animation = @getComp('animation')
    samus = @getComp('samus')

    oldState = animation.get('state')

    keyPath = [
      samus.get('motion')
      samus.get('direction')
      samus.get('aim')
      samus.get('recoil')
    ]
    newState = ObjectUtils.getDeep states, keyPath

    # TODO : refactor this gorpy implementation.
    if damaged = @getEntityComponent(@eid(), 'damaged')
      animation = animation.update 'visible', (v) -> !v
      animationChanged = true
    else
      animation = animation.set('visible',true)
      animationChanged = true

    if newState != oldState
      animation = animation.set('state',newState).set('time',0)
      animationChanged = true

    if animationChanged
      @updateComp animation

module.exports = SamusAnimationSystem

