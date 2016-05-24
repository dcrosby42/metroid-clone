Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

class MissileSystem extends BaseSystem
  @Subscribe: [ 'missile', 'hit_box', 'animation', 'velocity' ]

  process: ->
    hitBox = @getComp('hit_box')
    if hitBox.get('touchingSomething')
      @_detonate()
  _detonate: ->
    box = new AnchoredBox(@getComp('hit_box').toJS())
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
    
    @destroyEntity()

    # @deleteComp hitBox
    # @setProp 'animation', 'state', 'splode'
    # @setProp 'velocity', 'x', 0
    # @setProp 'velocity', 'y', 0
    # @addComp Common.DeathTimer.merge
    #   time: 6*(1000/60)

  _createShrapnel: (spriteName, spriteState, x,y, vx, vy) ->
    @newEntity [
      Common.Animation.merge
        layer: 'creatures'
        spriteName: spriteName
        state: spriteState
      Common.MapGhost
      Common.HitBox.merge
        width: 7
        height: 7
        anchorX: 0.54
        anchorY: 0.54
      Common.Position.merge
        x: x
        y: y
      Common.Velocity.merge
        x: vx
        y: vy
      Common.DeathTimer.merge
        time: 75
    ]

module.exports = MissileSystem

