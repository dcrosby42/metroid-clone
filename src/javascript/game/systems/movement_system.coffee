
class MovementSystem
  run: (estore, dt, input) ->
    for movement in estore.getComponentsOfType('movement')
      position = estore.getComponent(movement.eid, 'position')

      position.x += movement.x
      position.y += movement.y

module.exports = MovementSystem

