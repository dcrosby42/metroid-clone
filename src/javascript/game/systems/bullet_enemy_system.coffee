Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

class BulletEnemySystem extends BaseSystem
  @Subscribe: [
      [ "bullet", "hit_box" ],
      [ "enemy", "hit_box", "visual"]
    ]

  process: ->
    bulletHitBox = @get('bullet-hit_box')
    enemyHitBox = @get('enemy-hit_box')
    
    bulletBox = new AnchoredBox(bulletHitBox.toJS())
    enemyBox = new AnchoredBox(enemyHitBox.toJS())

    if bulletBox.overlaps(enemyBox)
      @update bulletHitBox.set('touchingSomething',true)

      # Play hit sound:
      hitSound = Common.Sound.merge
        soundId: 'enemy_die1'
        volume: 0.15
        playPosition: 0
        timeLimit: 170
      @newEntity [ hitSound ]

      # Deal damage to enemy:
      @updateProp 'enemy', 'hp', (hp) => hp - @getProp('bullet', 'damage')

      # Update or remove entity based on HP remaining:
      if @getProp('enemy', 'hp') > 0
        @setProp 'enemy','stunned', 200
        
      else
        @destroyEntity @getProp('enemy','eid')

        @newEntity [
          Common.Visual.merge
            layer: 'creatures'
            spriteName: 'creature_explosion'
            state: 'explode'
          Common.Position.merge
            x: enemyBox.left + (enemyBox.width/2)
            y: enemyBox.top + (enemyBox.height/2)
          Common.DeathTimer.merge
            time: 3 * (1000/20) # the splode anim lasts three or four twentieths of a second
        ]


module.exports = BulletEnemySystem
