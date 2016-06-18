BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'


class MorphBallVelocitySystem extends BaseSystem
  @Subscribe: [ T.MorphBall, T.Velocity ]

  process: (r) ->
    [morphBall, velocity] = r.comps
    @handleEvents r.eid,
      rollRight: => velocity.x = morphBall.rollSpeed
      rollLeft: => velocity.x = -morphBall.rollSpeed
      stop:      => velocity.x = 0

module.exports = -> new MorphBallVelocitySystem()

