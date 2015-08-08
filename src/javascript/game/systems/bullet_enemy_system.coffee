Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

class BulletEnemySystem extends BaseSystem
  @Subscribe: [
      [ "bullet", "hit_box" ],
      [ "enemy", "hit_box", "visual"]
    ]
  @ImplyEntity: 'enemy'

  process: ->
    bulletHitBox = @get('bullet-hit_box')
    enemyHitBox = @get('enemy-hit_box')
    
    bulletBox = new AnchoredBox(bulletHitBox.toJS())
    enemyBox = new AnchoredBox(enemyHitBox.toJS())

    if bulletBox.overlaps(enemyBox)
      @update bulletHitBox.set('touchingSomething',true)
      @publishEvent @eid(), 'shot'

module.exports = BulletEnemySystem
