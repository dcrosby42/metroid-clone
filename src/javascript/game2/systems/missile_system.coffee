BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'
AnchoredBox = require '../../utils/anchored_box'

class MissileSystem extends BaseSystem
  @Subscribe: [ T.Missile, T.HitBox, T.Animation, T.Velocity]

  process: (r) ->
    [missile,hitBox,animation,velocity] = r.comps

    if hitBox.touchingSomething
      box = new AnchoredBox(hitBox)
      x = box.centerX
      y = box.centerY

      magnitude = 0.5
      rad = Math.PI / 3
      ax = magnitude * Math.cos(rad)
      ay = magnitude * Math.sin(rad)

      @_createShrapnel('missile_shrapnel', 'right', x,y, magnitude, 0)
      @_createShrapnel('missile_shrapnel', 'left', x,y, -magnitude, 0)
      @_createShrapnel('missile_shrapnel', 'up-right', x,y, ax,-ay)
      @_createShrapnel('missile_shrapnel', 'up-left', x,y, -ax,-ay)
      @_createShrapnel('missile_shrapnel', 'down-right', x,y, ax,ay)
      @_createShrapnel('missile_shrapnel', 'down-left', x,y, -ax,ay)
      
      r.entity.destroy()

  _createShrapnel: (spriteName, spriteState, x,y, vx, vy) ->
    @estore.createEntity Prefab.missileShrapnel(
      animation:
        layer: 'creatures'
        spriteName: spriteName
        state: spriteState
      position:
        x: x
        y: y
      velocity:
        x: vx
        y: vy
    )



module.exports = -> new MissileSystem()

