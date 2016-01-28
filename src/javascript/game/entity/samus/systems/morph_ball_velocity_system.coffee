BaseSystem = require '../../../../ecs/base_system'


class MorphBallVelocitySystem extends BaseSystem
  @Subscribe: [ 'morph_ball', 'samus', 'velocity' ]

  process: ->
    samus = @getComp('samus')
    # direction = samus.get('direction')
    @handleEvents
      rollRight: => @setProp 'velocity', 'x', samus.get('runSpeed')
      rollLeft:  => @setProp 'velocity', 'x', -samus.get('runSpeed')
      stop:      => @setProp 'velocity', 'x', 0

module.exports = MorphBallVelocitySystem

