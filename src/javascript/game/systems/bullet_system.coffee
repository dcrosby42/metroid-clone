class BulletSystem
  run: (estore, dt, input) ->
    for bullet in estore.getComponentsOfType('bullet')
      hitBox = estore.getComponent bullet.eid, 'hit_box'
      if hitBox.touchingSomething
        console.log "BulletSystem TOUCH"
        estore.destroyEntity bullet.eid

module.exports = BulletSystem

