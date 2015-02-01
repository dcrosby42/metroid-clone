Common = require '../entity/components'
class BulletSystem
  run: (estore, dt, input) ->
    for bullet in estore.getComponentsOfType('bullet')
      hitBox = estore.getComponent bullet.eid, 'hit_box'
      if hitBox.touchingSomething
        
        pos = estore.getComponent bullet.eid, 'position'
        estore.createEntity [
          new Common.Visual
            layer: 'creatures'
            spriteName: 'bullet'
            state: 'splode'
          new Common.Position
            x: pos.x
            y: pos.y
          new Common.DeathTimer
            time: 3 * (1000/60) # 3 frames is 50 ms
        ]

        estore.destroyEntity bullet.eid

module.exports = BulletSystem

