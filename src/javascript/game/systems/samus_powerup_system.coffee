Common = require '../entity/components'
Items = require '../entity/items'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'


class SamusPowerupSystem extends BaseSystem
  @Subscribe: [
      [ "samus", "hit_box" ],
      [ "powerup", "hit_box"]
    ]
  @ImplyEntity: 'powerup'

  process: ->
    samusHitBox = @getComp('samus-hit_box')
    powerupHitBox = @getComp('powerup-hit_box')
    
    samusBox = new AnchoredBox(samusHitBox.toJS())
    powerupBox = new AnchoredBox(powerupHitBox.toJS())

    if samusBox.overlaps(powerupBox)
      @addComp Items.components.Collected.merge
        byEid: @getProp('samus','eid')
        
      @publishGlobalEvent 'PowerupTouched'


module.exports = SamusPowerupSystem
