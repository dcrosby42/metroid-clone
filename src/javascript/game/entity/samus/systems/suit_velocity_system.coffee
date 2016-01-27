BaseSystem = require '../../../../ecs/base_system'


class SuitVelocitySystem extends BaseSystem
  @Subscribe: [ 'suit', 'samus', 'velocity' ]

  process: ->
    samus = @getComp('samus')
    direction = samus.get('direction')
    @handleEvents
      run: =>
        if direction == 'right'
          @setProp 'velocity', 'x', samus.get('runSpeed')
        else
          @setProp 'velocity', 'x', -samus.get('runSpeed')

      drift: =>
        if direction == 'right'
          @setProp 'velocity', 'x', samus.get('floatSpeed')
        else
          @setProp 'velocity', 'x', -samus.get('floatSpeed')

      stop: =>
        @setProp 'velocity', 'x', 0

      jump: =>
        @setProp 'velocity', 'y', -samus.get('jumpSpeed')

      fall: =>
        @setProp 'velocity', 'y', 0


module.exports = SuitVelocitySystem

