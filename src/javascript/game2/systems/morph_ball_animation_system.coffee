BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'

class MorphBallAnimationSystem extends BaseSystem
  @Subscribe: [ T.MorphBall, T.Animation ]  # 'morph_ball', 'samus', 'animation' ]

  process: (r) ->
    [morphBall, animation] = r.comps

    oldState = animation.state

    newState = if morphBall.direction == 'left'
      'roll-left'
    else
      'roll-right'

    # TODO : refactor this gorpy implementation.
    # Two bad things:
    #   1) flickering stunt just toggles visible on each tick. not great.
    #   2) comp search for 'Damaged' component
    # ...but it works so it isn't getting attention
    # THREE, three bad things: duped in SuitAnimationSystem
    if damaged = r.entity.get(T.Damaged)
      animation.visible = !animation.visible
    else
      animation.visible = true

    if newState != oldState
      animation.state = newState
      animation.time = 0


module.exports = -> new MorphBallAnimationSystem()

