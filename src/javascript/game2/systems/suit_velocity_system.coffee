BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types


class SuitVelocitySystem extends BaseSystem
  # @Subscribe: [ 'suit', 'samus', 'velocity' ]
  @Subscribe: [ T.Suit, T.Velocity ]

  process: (r) ->
    [suit,velocity] = r.comps
    @handleEvents
      run: =>
        # if @getProp('samus','direction') == 'right'
        if suit.direction == 'right'
          velocity.x == suit.runSpeed
          # @setProp 'velocity', 'x', @getProp('samus','runSpeed')
        else
          # @setProp 'velocity', 'x', -@getProp('samus','runSpeed')
          velocity.x == -suit.runSpeed

      drift: =>
        # if @getProp('samus','direction') == 'right'
        if suit.direction == 'right'
          # @setProp 'velocity', 'x', @getProp('samus','floatSpeed')
          velocity.x == suit.floatSpeed
        else
          # @setProp 'velocity', 'x', -@getProp('samus','floatSpeed')
          velocity.x == -suit.floatSpeed

      stop: =>
        # @setProp 'velocity', 'x', 0
        velocity.x = 0

      jump: =>
        # @setProp 'velocity', 'y', -@getProp('samus','jumpSpeed')
        velocity.y = -suit.jumpSpeed

      fall: =>
        # @setProp 'velocity', 'y', 0
        velocity.y = 0

# jumping, falling, standing, running
module.exports = -> new SuitVelocitySystem()

