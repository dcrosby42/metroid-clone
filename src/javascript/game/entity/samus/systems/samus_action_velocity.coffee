BaseSystem = require '../../../../ecs/base_system'

class SamusActionVelocitySystem extends BaseSystem
  @Subscribe: [ 'samus', 'velocity' ]

  process: ->
    # samus actions: run | drift | stand | jump | fall
    samus = @getComp('samus')
    velocity = @getComp('velocity')

    direction = samus.get('direction')

    v2 = switch samus.get('action')
      when 'run'
        if direction == 'right'
          velocity.set('x', samus.get('runSpeed'))
        else
          velocity.set('x', -samus.get('runSpeed'))

      when 'drift'
        if direction == 'right'
          velocity.set('x', samus.get('floatSpeed'))
        else
          velocity.set('x', -samus.get('floatSpeed'))

      when 'stop'
        velocity.set('x', 0)

      when 'jump'
        velocity.set('y', -samus.get('jumpSpeed'))

      when 'fall'
        velocity.set('y', 0)

      else
        velocity

    if v2 != velocity
      @updateComp v2

module.exports = SamusActionVelocitySystem

