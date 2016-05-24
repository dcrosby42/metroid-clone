Common = require '../../components'
AnchoredBox = require '../../../../utils/anchored_box'
BaseSystem = require '../../../../ecs/base_system'

class MissileDoorSystem extends BaseSystem
  @Subscribe: [
      [ "missile", "hit_box" ],
      [ "door_gel", "hit_box"]
    ]
  @ImplyEntity: 'door_gel'

  process: ->
    missileHitBox = @getComp('missile-hit_box')
    gelHitBox = @getComp('door_gel-hit_box')
    
    missileBox = new AnchoredBox(missileHitBox.toJS())
    gelBox = new AnchoredBox(gelHitBox.toJS())

    if missileBox.overlaps(gelBox)
      @updateComp missileHitBox.set('touchingSomething',true)
      @publishEvent 'shot', 'missile'

module.exports = MissileDoorSystem
