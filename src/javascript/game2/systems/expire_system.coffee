BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

class ExpireSystem extends BaseSystem
  @Subscribe: [T.Expire]

  process: (r) ->
    if @getEvent r.eid, 'deathTimer'
      e.entity.destroy()

module.exports = -> new ExpireSystem()
