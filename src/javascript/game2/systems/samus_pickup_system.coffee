BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'
# Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
# BaseSystem = require '../../ecs/base_system'
# Items = require '../entity/items'
# Immutable = require 'immutable'


class SamusPickupSystem extends BaseSystem
  @Subscribe: [
      [ {type:T.Tag, name:'samus'}, T.HitBox ],
      [ T.Pickup, T.HitBox ]
      [ T.CollectedItems ]
    ]

  process: (samusR,pickupR,collectedItemsR) ->
    [samus,samusHitBox] = samusR.comps
    [pickup,pickupHitBox] = pickupR.comps
    [collectedItems] = collectedItemsR.comps
    
    samusBox = new AnchoredBox(samusHitBox)
    pickupBox = new AnchoredBox(pickupHitBox)

    if samusBox.overlaps(pickupBox)
      # TODO: emit pickup event?
      switch pickup.itemType
        when 'health_drop'
          healthComp = samusR.entity.get(T.Health)
          healthComp.hp += pickup.data
          @_makePickupSound()

        when 'missile_container'
          mcount = pickup.data
          console.log "Missiles +",mcount
          missiles = samusR.entity.get(T.MissileLauncher)
          if missiles
            missiles.max += mcount
            missiles.count += mcount
          else
            samusR.entity.addComponent C.buildCompForType(T.MissileLauncher,
              max: mcount
              count: mcount
            )
          @_celebrate()

        when 'maru_mari'
          samusR.entity.addComponent C.buildCompForType(T.MaruMari) # state: 'inactive'
          @_celebrate()

        else
          console.log "!! SamusPickupSystem: No reaction to Pickup",pickup

      if pickup.itemId?
        collectedItems.itemIds.push(pickup.itemId)
      pickupR.entity.destroy()

  _makePickupSound: ->
    @estore.createEntity Prefab.sound(
        soundId: 'health'
        volume: 0.5
        playPosition: 0
        timeLimit: 245
    )

  _celebrate: ->
      @estore.createEntity [C.buildCompForType(T.PowerupCelebration)]
      @publishGlobalEvent 'PowerupCelebrationStarted'

module.exports = -> new SamusPickupSystem()
