AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'
FilterExpander = require '../../ecs/filter_expander'

# Things like doors are "map fixtures"
fixtureFilter = FilterExpander.expandFilterGroups(['map_fixture', 'hit_box'])

class MapPhysicsSystem extends BaseSystem
  @Subscribe: [
    ['map_collider', 'velocity','hit_box','position']
  ]

  process: ->
    velocity = @getComp('map_collider-velocity')
    hitBox = @getComp('map_collider-hit_box')
    position = @getComp('map_collider-position')
    worldMap = @input.getIn(['static','worldMap'])

    vx = velocity.get('x')
    vy = velocity.get('y')
    hitBoxJS = hitBox.toJS()

    box = new AnchoredBox(hitBoxJS)
    box.setXY position.get('x'), position.get('y')

    #  map fixtures are doors, etc
    fboxes = []
    @searchEntities(fixtureFilter).forEach (comps) ->
      fboxes.push( new AnchoredBox(comps.get('hit_box').toJS()) )

    hits =
      left: []
      right: []
      top: []
      bottom: []

    adjacent =
      left: null
      right: null
      top: null
      bottom: null

    # Apply & restrict VERTICAL movement
    box.moveY(vy * @dt())

    hits.top = worldMap.tileSearchHorizontal(box.top, box.left, Math.ceil(box.right))
    if hits.top.length > 0
      tile = hits.top[0]
      box.setY(tile.worldY+tile.height - box.topOffset)
      adjacent.top = hits.top
    else
      hits.bottom = worldMap.tileSearchHorizontal(Math.ceil(box.bottom), box.left, Math.ceil(box.right))
      if hits.bottom.length > 0
        tile = hits.bottom[0]
        box.setY(tile.worldY - box.bottomOffset-1)
        adjacent.bottom = hits.bottom


    unless adjacent.top?
      adjacent.top = worldMap.tileSearchHorizontal(box.top-1, box.left, box.right-1)
    unless adjacent.bottom?
      adjacent.bottom = worldMap.tileSearchHorizontal(Math.ceil(box.bottom+1), box.left, box.right-1)


    # Step 2: apply & restrict horizontal movement
    box.moveX(vx * @dt())

    # (check non-map-tile map fixture collisions, like doors and disappearing blocks)
    for fbox in fboxes
      if box.overlaps(fbox)
        if box.centerX < fbox.centerX
          box.moveX(fbox.left - box.right)#- 1)
          adjacent.right = [fbox]
        else
          box.moveX(fbox.right - box.left)#+ 1)
          adjacent.left = [fbox]
          
    # (check map tiles)
    hits.left = worldMap.tileSearchVertical(box.left, box.top, Math.ceil(box.bottom))
    if hits.left.length > 0
      tile = hits.left[0]
      box.setX(tile.worldX+tile.width - box.leftOffset)
      adjacent.left = hits.left
    else
      hits.right = worldMap.tileSearchVertical(Math.ceil(box.right), box.top,box.bottom-1)
      if hits.right.length > 0
        tile = hits.right[0]
        box.setX(tile.worldX - box.rightOffset-1)
        adjacent.right = hits.right

    unless adjacent.left?
      adjacent.left = worldMap.tileSearchVertical(box.left-1, box.top, box.bottom-1)
    unless adjacent.right?
      adjacent.right = worldMap.tileSearchVertical(Math.ceil(box.right+1), box.top, box.bottom-1)
    
    # Update position and hit_box components 
    @updateComp position.set('x', box.x).set('y', box.y)

    # some systems will expect the hitBox to be up-to-date with current position
    hitBoxJS = {}
    hitBoxJS.x = box.x
    hitBoxJS.y = box.y
    hitBoxJS.touching = {}
    hitBoxJS.touching.left = hits.left.length > 0
    hitBoxJS.touching.right = hits.right.length > 0
    hitBoxJS.touching.top = hits.top.length > 0
    hitBoxJS.touching.bottom = hits.bottom.length > 0

    hitBoxJS.adjacent = {}
    hitBoxJS.adjacent.top = adjacent.top.length > 0
    hitBoxJS.adjacent.bottom = adjacent.bottom.length > 0
    hitBoxJS.adjacent.left = adjacent.left.length > 0
    hitBoxJS.adjacent.right = adjacent.right.length > 0
    hitBoxJS.touchingSomething = hitBoxJS.touching.left or hitBoxJS.touching.right or hitBoxJS.touching.top or hitBoxJS.touching.bottom or hitBoxJS.adjacent.left or hitBoxJS.adjacent.right or hitBoxJS.adjacent.top or hitBoxJS.adjacent.bottom

    @updateComp hitBox.merge(hitBoxJS)

    # Update velocity if needed based on running into objects:
    if hitBoxJS.touching.left or hitBoxJS.touching.right
      vx = 0

    if hitBoxJS.touching.top or hitBoxJS.touching.bottom
      vy = 0
    
    @updateComp velocity.set('x',vx).set('y',vy)

module.exports = MapPhysicsSystem

