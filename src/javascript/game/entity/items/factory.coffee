Items = require('./components')
Common = require('../components')
Immutable = require('immutable')

generalDefaults = Immutable.fromJS
  pickup: Items.Pickup
  animation: Common.Animation.merge
    state: 'default'
    layer: 'creatures'
  position: Common.Position
  hitBox: Common.HitBox.merge
      width: 8
      height: 8
      anchorX: 0.5
      anchorY: 0.5
  hitBoxVisual: Common.HitBoxVisual.merge
      color: 0xcccccc
      layer: 'creatures'
  name: Common.Name

defaultsByType = Immutable.fromJS
  health_drop:
    pickup:
      data: 5
    animation:
      spriteName: 'health_drop'
    hitBox:
      width: 8
      height: 8
      anchorX: -1.75 + 2.5*(0.0625)
      anchorY: -1.75 + 0.0625
    deathTimer: Common.DeathTimer.merge(time: 7000)

  missile_container:
    pickup:
      data: 5
    animation:
      spriteName: 'missile_container'
    hitBoxVisual:
      color: 0x33ff33

  maru_mari:
    animation:
      spriteName: 'maru_mari'
    hitBoxVisual:
      color: 0x33ff33

#
# Create a new pickup by applying type-specific defaults according to args->pickup->itemType.
#
createPickup = (args) ->
  # console.log "createPickup\n  args",args
  # console.log "  generalDefaults",generalDefaults.toJS()
  compMap = generalDefaults.mergeDeep(args)
  # console.log "  compMap w gen+args",compMap.toJS()
  itemType = compMap.get('pickup').get('itemType')
  # console.log "  itemType",itemType
  compMap = compMap.mergeDeep(defaultsByType.get(itemType))
  # console.log "  compMap w defaultsByType",compMap.toJS()

  # Default the entity name to itemType if not otherwise provided
  compMap = compMap.update 'name', (nameComp) ->
    nameComp.set('name', itemType) if !nameComp.get('name')?

  # TODO fix the health sprite. this is a dirty hack to offset it up/left by 16
  if itemType == 'health_drop'
    compMap = compMap.update 'position', (pos) -> pos.set('x',pos.get('x') - 16).set('y',pos.get('y')-16)

  # Copy position x,y into the hitbox
  pos = compMap.get('position')
  compMap = compMap.update 'hitBox', (hitBox) ->
    hitBox
      .set('x',pos.get('x'))
      .set('y',pos.get('y'))

  # console.log "  compMap after cleanup",compMap.toJS()
  return compMap.valueSeq()
  
module.exports =
  createPickup: createPickup
