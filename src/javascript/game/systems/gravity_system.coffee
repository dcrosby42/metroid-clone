class GravitySystem
  run: (estore, dt, input) ->
    gravities = estore.getComponentsOfType('gravity')
    for gravity in gravities
      velocity = estore.getComponent gravity.eid, 'velocity'
      if velocity?
        velocity.y += gravity.accel
        velocity.y = gravity.max if velocity.y > gravity.max

module.exports = GravitySystem

