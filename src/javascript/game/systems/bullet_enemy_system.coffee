Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'

makeEnemyHitSound = (u) ->


module.exports =
  config:
    filters: [
      [ "bullet", "hit_box" ],
      #[ "enemy", "hit_box" ]
      [ "enemy", "hit_box", "visual"]
    ]

  update: (comps,input,u) ->
    bulletHitBox = comps.get('bullet-hit_box')
    enemyHitBox = comps.get('enemy-hit_box')
    
    bulletBox = new AnchoredBox(bulletHitBox.toJS())
    enemyBox = new AnchoredBox(enemyHitBox.toJS())

    if bulletBox.overlaps(enemyBox)
      bullet = comps.get('bullet')
      enemy = comps.get('enemy')
      u.update bulletHitBox.set('touchingSomething',true)


      # Play hit sound:
      hitSound = Common.Sound.merge
        soundId: 'enemy_die1'
        volume: 0.15
        playPosition: 0
        timeLimit: 170
      u.newEntity [ hitSound ]

      # Deal damage to enemy:
      enemy = enemy.update 'hp', (hp) -> hp - bullet.get('damage')

      # Update or remove entity based on HP remaining:
      if enemy.get('hp') > 0
        
        # visual = comps.get('enemy-visual') #XXX
        # u.update visual.set('paused',true) #XXX
        u.update enemy.set('stunned',200) #XXX
      else
        u.destroyEntity enemy.get('eid')

        u.newEntity [
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



