BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

class MapGhostSystem extends BaseSystem
  @Subscribe: [{type:T.Tag, name:'map_ghost'}, T.Velocity, T.Position ]

  process: (r) ->
    [_mg, velocity, position] = r.comps

    position.x += velocity.x * @dt()
    position.y += velocity.y * @dt()

    hitBox = r.entity.get(T.HitBox)
    if hitBox?
      hitBox.x = position.x
      hitBox.y = position.y

module.exports = -> new MapGhostSystem()

