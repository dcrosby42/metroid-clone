BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

class AnimationTimerSystem extends BaseSystem
  @Subscribe: [T.Animation]

  process: (r) ->
    anim = r.comps[0]
    unless anim.paused
      anim.time += @dt()

module.exports = -> new AnimationTimerSystem()
