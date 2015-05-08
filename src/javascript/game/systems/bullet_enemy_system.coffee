Common = require '../entity/components2'
AnchoredBox = require '../../utils/anchored_box'

module.exports =
  config:
    filters: [
      [ "bullet", "hit_box" ],
      [ "enemy", "hit_box" ]
    ]

  update: (comps,input,u) ->
    bulletHitBox = comps.get('bullet-hit_box')
    enemyHitBox = comps.get('enemy-hit_box')
    eid = bulletHitBox.get('eid')
    
    bulletBox = new AnchoredBox(bulletHitBox.toJS())
    enemyBox = new AnchoredBox(enemyHitBox.toJS())

    if bulletBox.overlaps(enemyBox)
      console.log "** SHOT AN ENEMY **"
      u.update bulletHitBox.set('touchingSomething',true)


