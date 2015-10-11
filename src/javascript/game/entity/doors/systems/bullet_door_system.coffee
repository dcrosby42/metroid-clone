Common = require '../../components'
AnchoredBox = require '../../../../utils/anchored_box'
BaseSystem = require '../../../../ecs/base_system'

class BulletDoorSystem extends BaseSystem
  @Subscribe: [
      [ "bullet", "hit_box" ],
      [ "door_gel", "hit_box"]
    ]
  @ImplyEntity: 'door_gel'

  process: ->
    bulletHitBox = @getComp('bullet-hit_box')
    gelHitBox = @getComp('door_gel-hit_box')
    
    bulletBox = new AnchoredBox(bulletHitBox.toJS())
    gelBox = new AnchoredBox(gelHitBox.toJS())

    if bulletBox.overlaps(gelBox)
      @updateComp bulletHitBox.set('touchingSomething',true)
      @publishEvent 'shot', 'bullet'

module.exports = BulletDoorSystem
