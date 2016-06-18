BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'
AnchoredBox = require '../../utils/anchored_box'

class SamusHitSystem extends BaseSystem
  @Subscribe: [
      [ {type:T.Tag, name:"samus"}, {type:T.Tag, name:"vulnerable"}, T.HitBox ],
      [ T.Harmful, T.HitBox]
    ]

  process: (samusR,harmfulR) ->
    [samus,vuln,samusHitBox] = samusR.comps
    [harmful,harmfulHitBox] = harmfulR.comps
    
    samusBox = new AnchoredBox(samusHitBox)
    harmfulBox = new AnchoredBox(harmfulHitBox)

    if samusBox.overlaps(harmfulBox)
      kickX = if samusBox.centerX > harmfulBox.centerX then 0.02 else -0.02
      kickY = -0.05
      samusR.entity.addComponent Prefab.damagedComponent
        impulseX: kickX
        impulseY: kickY
        damage: harmful.damage
      samusR.entity.deleteComponent vuln

module.exports = -> new SamusHitSystem()
