Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

class SamusPickupSystem extends BaseSystem
  @Subscribe: [
      [ "samus", "hit_box" ],
      [ "pickup", "hit_box"]
    ]
  @ImplyEntity: 'samus'

  process: ->
    samusHitBox = @getComp('samus-hit_box')
    pickupHitBox = @getComp('pickup-hit_box')
    
    samusBox = new AnchoredBox(samusHitBox.toJS())
    pickupBox = new AnchoredBox(pickupHitBox.toJS())

    if samusBox.overlaps(pickupBox)
      pickup = @getComp('pickup')
      console.log "Pickup", pickup.toJS()
      item = pickup.get('item')
      value = pickup.get('value')
      switch item
        when 'health'
          healthComp = @getEntityComponent @eid(), 'health'
          @updateComp healthComp.update('hp', (hp) => hp + value)
        else
          console.log "--> No reaction for #{item}"

      @destroyEntity pickup.get('eid')
      @_makePickupSound()

  _makePickupSound: ->
    @newEntity [
      Common.Sound.merge
        soundId: 'health'
        # volume: 0.15
        volume: 0.5
        playPosition: 0
        timeLimit: 245
    ]


module.exports = SamusPickupSystem
