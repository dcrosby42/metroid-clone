Common = require '../entity/components2'
AnchoredBox = require '../../utils/anchored_box'

module.exports =
  config:
    filters: [
      { match: { type: 'bullet' }, as: 'bullet' }
      { match: { type: 'hit_box' }, as: 'bullet_hit_box', join: "bullet.eid" }

      { match: { type: 'enemy' }, as: 'enemy' }
      { match: { type: 'hit_box' }, as: 'enemy_hit_box', join: "enemy.eid" }
    ]

  update: (comps,input,u) ->
    bulletHitBox = comps.get('bullet_hit_box')
    enemyHitBox = comps.get('enemy_hit_box')
    eid = bulletHitBox.get('eid')

    bulletBox = new AnchoredBox(bulletHitBox.toJS())
    enemyBox = new AnchoredBox(comps.get('enemy_hit_box').toJS())

    if bulletBox.overlaps(enemyBox)
      console.log "** SHOT AN ENEMY **"
      u.update bulletHitBox.set('touchingSomething',true)


