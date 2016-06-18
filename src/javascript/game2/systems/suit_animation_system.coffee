BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
ObjectUtils = require '../../utils/object_utils'
_ = require 'lodash'

defs = [
  [['standing','right','straight'], 'stand-right']
  [['standing','right','up'],       'stand-right-aim-up']
  [['standing','left','straight'],  'stand-left']
  [['standing','left','up'],        'stand-left-aim-up']

  [['running','left','straight'],   'run-left']
  [['running','left','up'],         'run-left-aim-up']
  [['running','right','straight'],  'run-right']
  [['running','right','up'],        'run-right-aim-up']

  [['airborn','right','straight'],  'jump-right']
  [['airborn','right','up'],        'jump-right-aim-up']
  [['airborn','left','straight'],   'jump-left']
  [['airborn','left','up'],         'jump-left-aim-up']
]


states = {}
_.forEach defs, ([path,state]) =>
  ObjectUtils.setDeep states, path, state


class SuitAnimationSystem extends BaseSystem
  # @Subscribe: [ 'suit', 'samus', 'animation' ]
  @Subscribe: [ T.Suit, T.Animation ]

  process: (r) ->
    [suit,animation] = r.comps
    # animation = @getComp('animation')
    # samus = @getComp('samus')
    # suit = @getComp('suit')

    oldState = animation.state

    keyPath = [
      suit.pose
      suit.direction
      suit.aim
    ]
    newState = ObjectUtils.getDeep states, keyPath

    # TODO : refactor this gorpy implementation.
    # Two bad things:
    #   1) flickering stunt just toggles visible on each tick. not great.
    #   2) comp search for 'Damaged' component
    # ...but it works so it isn't getting attention
    # THREE, three bad things: duped in MorphBallAnimationSystem
    if damaged = r.entity.get(T.Damaged)
      animation.visible = !animation.visible
    else
      animation.visible = true

    if newState != oldState
      animation.state = newState
      animation.time = 0


module.exports = -> new SuitAnimationSystem()

