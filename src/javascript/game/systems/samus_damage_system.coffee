Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

class SamusDamageSystem extends BaseSystem
  @Subscribe: [
      [ "samus", "vulnerable", "hit_box", "velocity" ],
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
      kickX = if samusBox.centerX > harmfulBox.centerX then -0.2 else 0.2
      kickY = -0.5
      @updateProp 'samus-velocity', 'x', (x) -> x + kickX
      @updateProp 'samus-velocity', 'y', (y) -> y + kickY
      @deleteComp @getComp('samus-vulnerable')
      #XXX @updateComp samusHitBox.set('touchingSomething',true)
      #XXX @publishEvent 'shot'

module.exports = SamusDamageSystem
