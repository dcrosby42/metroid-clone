Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

class MissileEnemySystem extends BaseSystem
  @Subscribe: [
      [ "missile", "hit_box" ],
      [ "enemy", "hit_box"]
    ]
  @ImplyEntity: 'enemy'

  process: ->
    missileHitBox = @getComp('missile-hit_box')
    enemyHitBox = @getComp('enemy-hit_box')
    
    missileBox = new AnchoredBox(missileHitBox.toJS())
    enemyBox = new AnchoredBox(enemyHitBox.toJS())

    if missileBox.overlaps(enemyBox)
      @updateComp missileHitBox.set('touchingSomething',true)
      @publishEvent 'shot', @getProp('missile','damage')

module.exports = MissileEnemySystem
