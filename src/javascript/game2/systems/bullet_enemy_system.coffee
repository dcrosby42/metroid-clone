BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
AnchoredBox = require '../../utils/anchored_box'

class BulletEnemySystem extends BaseSystem
  @Subscribe: [
      [ T.Bullet, T.HitBox ],
      [ T.Enemy, T.HitBox ]
    ]

  process: (bulletR, enemyR) ->
    [bullet, bulletHitBox] = bulletR.comps
    [enemy, enemyHitBox] = enemyR.comps
    
    bulletBox = new AnchoredBox(bulletHitBox)
    enemyBox = new AnchoredBox(enemyHitBox)

    if bulletBox.overlaps(enemyBox)
      bulletHitBox.touchingSomething = true
      @publishEvent enemyR.eid, 'shot', bullet.damage

module.exports = -> new BulletEnemySystem()
