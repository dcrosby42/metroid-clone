class BulletSystem
  run: (estore, dt, input) ->
    for bullet in estore.getComponentsOfType('bullet')
      0
          # estore.removeComponent sound.eid, sound

module.exports = BulletSystem

