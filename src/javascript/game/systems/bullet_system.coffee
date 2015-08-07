Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

class BulletSystem extends BaseSystem
  @Subscribe: [ 'bullet', 'hit_box', 'visual', 'velocity', 'death_timer' ]

  process: ->
    hitBox = @get('hit_box')
    if hitBox.get('touchingSomething')
      @delete hitBox
      @setProp 'visual', 'state', 'splode'
      @setProp 'velocity', 'x', 0
      @setProp 'velocity', 'y', 0
      @setProp 'death_timer', 'time', 3*(1000/60)

module.exports = BulletSystem

