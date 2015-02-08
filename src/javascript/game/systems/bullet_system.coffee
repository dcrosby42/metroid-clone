Common = require '../entity/components'
_ = require 'lodash'
AnchoredBox = require '../../utils/anchored_box'

forComponentsWith = (estore, ctypes, fn) ->
  typeL = ctypes.shift()
  _.forEach estore.getComponentsOfType(typeL), (comp) ->
    compsR = _.map ctypes, (t) -> estore.getComponent(comp.eid, t)
    if _.every(compsR, (x) -> x?)
      fn(comp, compsR...)


  # if ctypes.length > 1
  #   ctype = ctypes.pop()
  #   forComponentsWith(estore, ctypes, newFn)
  # else if ctypes.length > 0
  #   _.forEach estore.getComponentsOfType(ctypes[0]), (comp) ->
  #     fn(comp)



  # compsL = estore.getComponentsOfType(typeL)
  # _.forEach compsL, (compL) ->
  #   if compR = estore.getComponent(compL.eid, typeR)
  #     fn(compL, compR)

class BulletSystem

  run: (estore, dt, input) ->
    shotEnemy = false
    forComponentsWith estore, ['bullet', 'hit_box'], (bullet, bulletHitBox) ->
      bulletBox = new AnchoredBox(bulletHitBox)
      forComponentsWith estore, ['enemy', 'hit_box'], (enemy, enemyHitBox) ->
        enemyBox = new AnchoredBox(enemyHitBox)
        if bulletBox.overlaps(enemyBox)
          shotEnemy = true
          console.log "SHOT! bullet=#{bullet.eid} enemy=#{enemy.eid}"
          # estore.pushEvent enemy.eid,
          #   eventType: 'collision'
          #   data:
          #     eid: bullet.eid

      hitBox = estore.getComponent bullet.eid, 'hit_box'
      if shotEnemy or hitBox.touchingSomething
        position = estore.getComponent bullet.eid, 'position'
        estore.createEntity [
          new Common.Visual
            layer: 'creatures'
            spriteName: 'bullet'
            state: 'splode'
          new Common.Position
            x: position.x
            y: position.y
          new Common.DeathTimer
            time: 3 * (1000/60) # 3 frames is 50 ms
        ]

        estore.destroyEntity bullet.eid
module.exports = BulletSystem

