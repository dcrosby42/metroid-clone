MathUtils = require '../../utils/math_utils'
BaseSystem = require '../../ecs/base_system'

class GravitySystem extends BaseSystem
  @Subscribe: ['gravity','velocity']

  process: ->
    gravity = @getComp('gravity')
    @updateProp 'velocity', 'y', (y) =>
      MathUtils.min(y + gravity.get('accel'), gravity.get('max'))

module.exports = GravitySystem


