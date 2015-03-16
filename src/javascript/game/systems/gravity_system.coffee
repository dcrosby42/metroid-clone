MathUtils = require '../../utils/math_utils'

module.exports =
  config:
    filters: ['gravity','velocity']

  update: (comps, input, u) ->
    velocity = comps.get('velocity')
    gravity = comps.get('gravity')
    velocity1 = velocity.update 'y', (y) ->
      MathUtils.min(y + gravity.get('accel'), gravity.get('max'))
    u.update velocity1

