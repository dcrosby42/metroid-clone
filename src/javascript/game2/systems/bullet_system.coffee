BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

class BulletSystem extends BaseSystem
  @Subscribe: [ T.Bullet, T.HitBox, T.Animation,T.Velocity,{type:T.Timer,eventName:'expire_entity'}]

  process: (r) ->
    [bullet,hitBox,animation,velocity,expireTimer] = r.comps
    if hitBox.touchingSomething
      r.entity.deleteComponent hitBox
      animation.state = 'splode'
      velocity.x = 0
      velocity.y = 0
      expireTimer.time = 3*(1000/60) # 3 more ticks so we can animate

module.exports = -> new BulletSystem()

