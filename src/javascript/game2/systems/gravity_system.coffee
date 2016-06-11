BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
MathUtils = require '../../utils/math_utils'

class GravitySystem extends BaseSystem
  @Subscribe: [T.Gravity,T.Velocity]

  process: (r) ->
    [gravity,velocity] = r.comps
    velocity.y = MathUtils.min(velocity.y + gravity.accel, gravity.max)

module.exports = -> new GravitySystem()


