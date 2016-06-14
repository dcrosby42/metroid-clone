BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

class TimerSystem extends BaseSystem
  @Subscribe: [T.Timer]

  process: (r) ->
    timer = r.comps[0]
    timer.time -= @dt()
    if timer.time <= 0
      @publishEvent r.eid, timer.eventName
      # console.log "TimerSystem published",r.eid, timer.eventName,timer
      r.entity.deleteComponent(timer)
      
module.exports = -> new TimerSystem()

