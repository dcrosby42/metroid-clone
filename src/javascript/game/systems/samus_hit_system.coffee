Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

class SamusHitSystem extends BaseSystem
  @Subscribe: [
      [ "samus", "vulnerable", "hit_box" ],
      [ "harmful", "hit_box"]
    ]
  @ImplyEntity: 'samus'

  process: ->
    samusHitBox = @getComp('samus-hit_box')
    harmfulHitBox = @getComp('harmful-hit_box')
    
    samusBox = new AnchoredBox(samusHitBox.toJS())
    harmfulBox = new AnchoredBox(harmfulHitBox.toJS())

    if samusBox.overlaps(harmfulBox)
      samusEid = @getProp('samus','eid')
      console.log ">> Samus #{samusEid} harmed by #{@getProp('harmful','eid')}"
      @deleteComp @getComp('samus-vulnerable')

      kickX = if samusBox.centerX > harmfulBox.centerX then 0.05 else -0.05
      kickY = -0.1
      @addEntityComp samusEid, Common.Damaged.merge
        impulseX: kickX
        impulseY: kickY
      #XXX @updateComp samusHitBox.set('touchingSomething',true)
      #XXX @publishEvent 'shot'

module.exports = SamusHitSystem
