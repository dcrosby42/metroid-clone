BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

class ExpireSystem extends BaseSystem
  @Subscribe: [{type:T.Tag, name:'expire_entity'}]

  process: (r) ->
    @handleEvents r.eid,
      deathTimer: ->
        e.entity.destroy()

module.exports = -> new ExpireSystem()
