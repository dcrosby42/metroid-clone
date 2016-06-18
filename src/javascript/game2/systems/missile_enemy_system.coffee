BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'
AnchoredBox = require '../../utils/anchored_box'

class MissileEnemySystem extends BaseSystem
  @Subscribe: [
    [T.Missile,T.HitBox]
    [T.Enemy,T.HitBox]
  ]

  process: (missileR,enemyR) ->
    [missile,missileHitBox] = missileR.comps
    [enemy,enemyHitBox] = enemyR.comps
    
    missileBox = new AnchoredBox(missileHitBox)
    enemyBox = new AnchoredBox(enemyHitBox)

    if missileBox.overlaps(enemyBox)
      missileHitBox.touchingSomething = true
      @publishEvent enemyR.eid, 'shot', missile.damage
module.exports = -> new MissileEnemySystem()
