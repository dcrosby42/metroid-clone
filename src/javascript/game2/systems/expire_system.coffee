BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

class ExpireSystem extends BaseSystem
  @Subscribe: [{type:T.Tag, name:'expire_entity'}]

  process: (r) ->
    # console.log "ExpireSystem events",@getEvents(r.eid)
    @handleEvents r.eid,
      expire_entity: ->
        r.entity.destroy()

module.exports = -> new ExpireSystem()
