Common = require '../entity/components'
Items = require '../entity/items'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'


class SamusPowerupSystem extends BaseSystem
  @Subscribe: [
      [ "samus", "hit_box" ]
      [ "powerup", "hit_box"]
      [ "collected_items" ]
    ]
  @ImplyEntity: 'powerup'

  process: ->
    samusHitBox = @getComp('samus-hit_box')
    powerupHitBox = @getComp('powerup-hit_box')
    
    samusBox = new AnchoredBox(samusHitBox.toJS())
    powerupBox = new AnchoredBox(powerupHitBox.toJS())

    if samusBox.overlaps(powerupBox)
      # Add the 'Collected' component to the powerup.  Triggers the powerup_collection system
      samusEid = @getProp('samus','eid')
      @addComp Items.components.Collected.merge(byEid: samusEid)

      # Identify this item as collected
      itemId = @getProp 'powerup','itemId'
      @updateProp 'collected_items', 'itemIds', (ids) -> ids.add(itemId)

      # Let the world know
      @publishGlobalEvent 'PowerupTouched'


module.exports = SamusPowerupSystem
