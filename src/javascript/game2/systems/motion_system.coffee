BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
# Immutable = require 'immutable'
Motions = require '../../components/motions'


class MotionSystem extends BaseSystem
  @Subscribe: [T.Motion, T.Velocity, T.HitBox]

  process: (r) ->
    [motion,velocity,hitBox] = r.comps

    # motions = []
    motions = new Motions()

    if velocity.y < 0
      motions.rising = true
    else if velocity.y > 0
      motions.falling = true
    else
      motions.yStill = true

    if hitBox.touching.bottom
      motions.touching = true
      motions.touchingBottom = true
    if hitBox.touching.top
      motions.touching = true
      motions.touchingTop = true
    if hitBox.adjacent.top
      motions.adjacent = true
      motions.adjacentTop = true

    if velocity.x > 0
      motions.movingSideways = true
      motions.movingRight = true
    else if velocity.x < 0
      motions.movingSideways = true
      motions.movingLeft = true
    else
      motions.xStill = true

    motion.motions = motions

module.exports = -> new MotionSystem()

