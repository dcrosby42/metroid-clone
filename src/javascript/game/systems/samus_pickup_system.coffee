Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'
Items = require '../entity/items'
Immutable = require 'immutable'


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
      pickup = @getComp('pickup') # itemType itemId data
      # TODO: emit pickup event?
      # itemType = pickup.get('itemType')
      switch pickup.get('itemType')
        when 'health_drop'
          healthComp = @getEntityComponent @eid(), 'health'
          @updateComp healthComp.update('hp', (hp) => hp + pickup.get('data'))
          @_makePickupSound()

        when 'missile_container'
          mcount = pickup.get('data')
          console.log "Missiles +",mcount
          missiles = @getEntityComponent @eid(), 'missile_launcher'
          if missiles
            missiles = missiles
              .set('max', mcount + missiles.get('max'))
              .set('count', mcount + missiles.get('count'))
            @updateComp missiles
          else
            missiles = Items.components.MissileLauncher.merge
              max: mcount
              count: mcount
            @addComp missiles
          @_celebrate()

        when 'maru_mari'
          console.log "Balls!"
          @addComp Items.components.MaruMari
          @_celebrate()

        else
          console.log "!! SamusPickupSystem: No reaction to Pickup",pickup

      @destroyEntity pickup.get('eid')

  _makePickupSound: ->
    @newEntity [
      Common.Sound.merge
        soundId: 'health'
        # volume: 0.15
        volume: 0.5
        playPosition: 0
        timeLimit: 245
    ]
  _celebrate: ->
      @newEntity [Items.components.PowerupCelebration]
      @publishGlobalEvent 'PowerupCelebrationStarted'

module.exports = SamusPickupSystem
