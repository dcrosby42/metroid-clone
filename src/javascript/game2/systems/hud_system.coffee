BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

class SamusHudSystem extends BaseSystem
  @Subscribe: [
    [{type:T.Tag,name:'samus'}, T.Health]
    [{type:T.Tag,name:'hud'}, T.Label]
  ]

  process: (samus,hud) ->
    health = samus.comps[1]
    label = hud.comps[1]
    label.content = "E.#{health.hp}"

module.exports = -> new SamusHudSystem()

