BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'
AnchoredBox = require '../../utils/anchored_box'

class MissileDoorSystem extends BaseSystem
  @Subscribe: [
    [T.Missile,T.HitBox]
    [T.DoorGel,T.HitBox,{type:T.Tag,name:'map_fixture'}]
  ]

  process: (missileR,gelR) ->
    [missile,missileHitBox] = missileR.comps
    [gel,gelHitBox] = gelR.comps
    
    missileBox = new AnchoredBox(missileHitBox)
    gelBox = new AnchoredBox(gelHitBox)

    if missileBox.overlaps(gelBox)
      missileHitBox.touchingSomething = true
      @publishEvent gelR.eid, 'shot', missile.damage

module.exports = -> new MissileDoorSystem()
