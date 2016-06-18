BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'
AnchoredBox = require '../../utils/anchored_box'

class BulletDoorSystem extends BaseSystem
  @Subscribe: [
      [ T.Bullet, T.HitBox ]
      [ T.DoorGel, T.HitBox ]
    ]

  process: (bulletR, doorR) ->
    [bullet,bulletHitBox] = bulletR.comps
    [gel,gelHitBox] = doorR.comps
    
    bulletBox = new AnchoredBox(bulletHitBox)
    gelBox = new AnchoredBox(gelHitBox)

    if bulletBox.overlaps(gelBox)
      bulletHitBox.touchingSomething = true
      @publishEvent doorR.eid, 'shot', 'bullet'

module.exports = -> new BulletDoorSystem()
