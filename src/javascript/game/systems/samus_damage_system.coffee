Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

class SamusDamageSystem extends BaseSystem
  @Subscribe: [
      [ "samus", "hit_box" ],
      [ "harmful", "hit_box"]
    ]
  @ImplyEntity: 'samus'

  process: ->
    samusHitBox = @getComp('samus-hit_box')
    harmfulHitBox = @getComp('harmful-hit_box')
    
    samusBox = new AnchoredBox(samusHitBox.toJS())
    harmfulBox = new AnchoredBox(harmfulHitBox.toJS())

    if samusBox.overlaps(harmfulBox)
      console.log ">> Samus harmed by #{@getProp('harmful','eid')}"
      #XXX @updateComp samusHitBox.set('touchingSomething',true)
      #XXX @publishEvent 'shot'

module.exports = SamusDamageSystem
