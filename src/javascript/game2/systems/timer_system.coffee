BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

class TimerSystem extends BaseSystem
  @Subscribe: [T.Timer]

  process: (r) ->
    timer = r.comps[0]
    timer.time -= @dt()
    if timer.time <= 0
      r.entity.delete(timer)
      @publishEvent r.eid, timer.get('name')
      
module.exports = -> new TimerSystem()

