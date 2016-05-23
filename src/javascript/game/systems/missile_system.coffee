Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

class MissileSystem extends BaseSystem
  @Subscribe: [ 'missile', 'hit_box', 'animation', 'velocity' ]

  process: ->
    hitBox = @getComp('hit_box')
    if hitBox.get('touchingSomething')
      @deleteComp hitBox
      @setProp 'animation', 'state', 'splode'
      @setProp 'velocity', 'x', 0
      @setProp 'velocity', 'y', 0
      @addComp Common.DeathTimer.merge
        time: 6*(1000/60)

module.exports = MissileSystem

