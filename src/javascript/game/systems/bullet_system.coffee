Common = require '../entity/components2'
AnchoredBox = require '../../utils/anchored_box'

module.exports =
  config:
    filters: [
      { match: { type: 'bullet' }, as: 'bullet' }
      { match: { type: 'hit_box' }, as: 'bullet_hit_box', join: "bullet.eid" }
      { match: { type: 'position' }, as: 'bullet_position', join: "bullet.eid" }
      #
      { match: { type: 'enemy' }, as: 'enemy' }
      # { match: { type: 'hit_box' }, as: 'enemy_hit_box', join: "enemy.eid" }
    ]

  update: (comps,input,u) ->
    bullet = comps.get("bullet")

    hit = bulletHitBox.get('touchingSomething')

    shotEnemy = false
    bulletHitBox = comps.get('bullet_hit_box')
    bulletBox = new AnchoredBox(bulletHitBox.toJS())
    enemyBox = new AnchoredBox(comps.get('enemy_hit_box').toJS())

    if bulletBox.overlaps(enemyBox)
      shotEnemy = true
      console.log "SHOT! bullet=#{comps.get('bullet').get('eid')} enemy=#{comps.get('enemy').get('eid')}"

    if hit or shotEnemy
      position = comps.get('bullet_position')
      console.log "HIT @ #{position.toString()}"
      u.newEntity [
        Common.Visual.merge
          layer: 'creatures'
          spriteName: 'bullet'
          state: 'splode'
        Common.Position.merge
          x: position.get('x')
          y: position.get('y')
        Common.DeathTimer.merge
          time: 3 * (1000/60) # 3 frames is 50 ms
      ]
      
      u.destroyEntity bullet.get('eid')
