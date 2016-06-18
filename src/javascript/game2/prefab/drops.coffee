C = require '../../components'
T = C.Types
Helpers = require './helpers'
{name,tag,buildComp,emptyComp} = Helpers
General = require './general'

buildGenericDrop = -> [
  buildComp T.Pickup
  buildComp T.Animation,
    state: 'default'
    layer: 'creatures'
  buildComp T.Position
  buildComp T.HitBox,
    width: 8
    height: 8
    anchorX: 0.5
    anchorY: 0.5
  buildComp T.HitBoxVisual,
    color: 0xcccccc
    layer: 'creatures'
  buildComp T.Name
]

defaultsByType =
  health_drop: -> [
    emptyComp T.Pickup,
      itemType: 'health_drop'
      data: 5
    emptyComp T.Animation,
      spriteName: 'health_drop'
    emptyComp T.HitBox,
      width: 8
      height: 8
      anchorX: -1.75 + 2.5*(0.0625)
      anchorY: -1.75 + 0.0625
  ].concat(General.deathTimer(7000))

  missile_container: -> [
    emptyComp T.Pickup,
      data: 5
    emptyComp T.Animation,
      spriteName: 'missile_container'
    emptyComp T.HitBoxVisual,
      color: 0x33ff33
  ]

  maru_mari: -> [
    emptyComp T.Animation,
      spriteName: 'maru_mari'
    emptyComp T.HitBoxVisual,
      color: 0x33ff33
  ]

  
findComp = (comps,t) ->
  for comp in comps
    return comp if comp.type == t
  return null

mergeComp = (a,b) ->
  for key,val of b
    if val? and typeof val != 'function'
      if key != 'type'
        a[key] = val

mergeCompListOnto = (comps, lists...) ->
  for list in lists
    for bcomp in list
      comp = findComp(comps, bcomp.type)
      if comp?
        mergeComp comp,bcomp
      else
        comps.push bcomp

Drops = {}
Drops.build = ({pickup,position}) ->
  itemType = pickup.itemType
  if !defaultsByType[itemType]?
    throw new Error("No such drop type '#{itemType}'",pickup)

  argComps = [
    emptyComp T.Pickup, pickup
    emptyComp T.Position, position
  ]
  # console.log "\n\n!! argComps:",argComps

  comps = buildGenericDrop()
  # console.log "\n\n!! comps:",comps
  specificComps = defaultsByType[itemType]()
  # console.log "\n\n!! specific:",specificComps
  mergeCompListOnto comps, specificComps, argComps
  # console.log "\n\n!! merged:",comps
  
  # Default the entity name to itemType if not otherwise provided
  nameComp = findComp comps, T.Name
  nameComp.name ?= itemType

  posComp = findComp comps, T.Position
  hitBoxComp = findComp comps, T.HitBox
  
  # TODO fix the health sprite. this is a dirty hack to offset it up/left by 16
  if itemType == 'health_drop'
    posComp.x -= 16
    posComp.y -= 16

  # Copy position x,y into the hitbox
  hitBoxComp.x = posComp.x
  hitBoxComp.y = posComp.y

  return comps

module.exports = Drops

# x = Drops.build(
#   pickup:
#     itemType: 'health_drop'
#   position:
#     x: 50
#     y: 70
# )
