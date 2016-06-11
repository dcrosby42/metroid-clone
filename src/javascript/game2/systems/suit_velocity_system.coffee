BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types


class SuitVelocitySystem extends BaseSystem
  # @Subscribe: [ 'suit', 'samus', 'velocity' ]
  @Subscribe: [ T.Suit, T.Velocity ]

  process: (r) ->
    [suit,velocity] = r.comps
    @handleEvents r.eid,
      run: =>
        # console.log "suitvelsys run", suit,velocity
        if suit.direction == 'right'
          velocity.x = suit.runSpeed
        else
          velocity.x = -suit.runSpeed

      drift: =>
        if suit.direction == 'right'
          velocity.x = suit.floatSpeed
        else
          velocity.x = -suit.floatSpeed

      stop: =>
        velocity.x = 0

      jump: =>
        velocity.y = -suit.jumpSpeed

      fall: =>
        velocity.y = 0

# jumping, falling, standing, running
module.exports = -> new SuitVelocitySystem()

