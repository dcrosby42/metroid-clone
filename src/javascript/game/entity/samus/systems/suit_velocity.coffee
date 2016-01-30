BaseSystem = require '../../../../ecs/base_system'


class SuitVelocitySystem extends BaseSystem
  @Subscribe: [ 'suit', 'samus', 'velocity' ]

  process: ->
    console.log "suit velocity"
    @handleEvents
      run: =>
        if @getProp('samus','direction') == 'right'
          @setProp 'velocity', 'x', @getProp('samus','runSpeed')
        else
          @setProp 'velocity', 'x', -@getProp('samus','runSpeed')

      drift: =>
        if @getProp('samus','direction') == 'right'
          @setProp 'velocity', 'x', @getProp('samus','floatSpeed')
        else
          @setProp 'velocity', 'x', -@getProp('samus','floatSpeed')

      stop: =>
        @setProp 'velocity', 'x', 0

      jump: =>
        @setProp 'velocity', 'y', -@getProp('samus','jumpSpeed')

      fall: =>
        @setProp 'velocity', 'y', 0

# jumping, falling, standing, running
module.exports = SuitVelocitySystem

