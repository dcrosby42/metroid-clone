BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
AnchoredBox = require '../../utils/anchored_box'
EntitySearch = require '../../ecs2/entity_search'

# Things like doors are "map fixtures"
# fixtureFilter = EntityStore.expandSearch(['map_fixture', 'hit_box'])
fixtureSearcher = EntitySearch.prepare([{type: T.Tag, name: 'map_fixture'},T.HitBox])

class MapPhysicsSystem extends BaseSystem
  # @Subscribe: [
  #   ['map_collider', 'velocity','hit_box','position']
  # ]
  @Subscribe: [ {type:T.Tag, name: 'map_collider'}, T.Velocity, T.HitBox, T.Position ]

  process: (r) ->
    # velocity = @getComp('map_collider-velocity')
    # hitBox = @getComp('map_collider-hit_box')
    # position = @getComp('map_collider-position')
    [_mapCollider, velocity, hitBox, position] = r.comps
    worldMap = @input.getIn(['static','worldMap'])

    vx = velocity.x
    # console.log vx
    vy = velocity.y
    # hitBoxJS = hitBox.toJS()

    box = new AnchoredBox(hitBox)
    box.setXY position.x, position.y

    #  map fixtures are doors, etc
    fboxes = []
    # @searchEntities(fixtureFilter).forEach (comps) ->
    fixtureSearcher.run @estore, (fixtureR) ->
      [_mapFixture,fixHitBox] = fixtureR.comps
      fboxes.push( new AnchoredBox(fixHitBox) )

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
    # @updateComp) position.set('x', box.x).set('y', box.y)
    position.x = box.x
    position.y = box.y

    # some systems will expect the hitBox to be up-to-date with current position
    # hitBox = {}
    hitBox.x = box.x
    hitBox.y = box.y
    hitBox.touching = {}
    hitBox.touching.left = hits.left.length > 0
    hitBox.touching.right = hits.right.length > 0
    hitBox.touching.top = hits.top.length > 0
    hitBox.touching.bottom = hits.bottom.length > 0
    # console.log "Mapphys",hitBox.touching.bottom

    hitBox.adjacent = {}
    hitBox.adjacent.top = adjacent.top.length > 0
    hitBox.adjacent.bottom = adjacent.bottom.length > 0
    hitBox.adjacent.left = adjacent.left.length > 0
    hitBox.adjacent.right = adjacent.right.length > 0
    hitBox.touchingSomething = hitBox.touching.left or hitBox.touching.right or hitBox.touching.top or hitBox.touching.bottom or hitBox.adjacent.left or hitBox.adjacent.right or hitBox.adjacent.top or hitBox.adjacent.bottom

    # @updateComp hitBox.merge(hitBoxJS)

    # Update velocity if needed based on running into objects:
    if hitBox.touching.left or hitBox.touching.right
      vx = 0

    if hitBox.touching.top or hitBox.touching.bottom
      # console.log "mapphys vy 0"
      vy = 0
    
    # @updateComp velocity.set('x',vx).set('y',vy)
    velocity.x = vx
    velocity.y = vy

module.exports = -> new MapPhysicsSystem()

