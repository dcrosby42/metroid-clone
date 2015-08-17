AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

tileSearchVertical = (grid, tw,th, x, topY, bottomY) ->
  hits = []
  c = Math.floor(x/tw)
  for r in [Math.floor(topY/th)..Math.floor(bottomY/th)]
    row = grid[r]
    if row?
      hit = grid[r][c]
      if hit?
        hits.push hit
  hits

tileSearchHorizontal = (grid, tw,th, y, leftX, rightX) ->
  hits = []
  r = Math.floor(y/th)
  row = grid[r]
  if row?
    for c in [Math.floor(leftX/tw)..Math.floor(rightX/tw)]
      hit = grid[r][c]
      if hit?
        hits.push hit
  hits

class MapPhysicsSystem extends BaseSystem
  @Subscribe: [
    ['map']
    ['map_collider', 'velocity','hit_box','position']
  ]

  process: ->
    velocity = @getComp('map_collider-velocity')
    hitBox = @getComp('map_collider-hit_box')
    position = @getComp('map_collider-position')

    mapDatabase = @input.getIn(['static','mapDatabase'])
    mapName = @getProp('map', 'name')
    map = mapDatabase.get(mapName)

    if !map?
      console.log "!! NO MAP NAMED '#{mapName}' in", @input.toJS()
    grid = map.tileGrid
    tileWidth = map.tileWidth
    tileHeight = map.tileHeight

    vx = velocity.get('x')
    vy = velocity.get('y')
    hitBoxJS = hitBox.toJS()

    box = new AnchoredBox(hitBoxJS)
    box.setXY position.get('x'), position.get('y')

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

    hits.top = tileSearchHorizontal(grid, tileWidth,tileHeight,box.top, box.left, box.right-1)
    if hits.top.length > 0
      s = hits.top[0]
      box.setY(s.y+s.height - box.topOffset)
      adjacent.top = hits.top
    else
      hits.bottom = tileSearchHorizontal(grid, tileWidth,tileHeight,Math.ceil(box.bottom), box.left, box.right-1)
      if hits.bottom.length > 0
        s = hits.bottom[0]
        box.setY(s.y - box.bottomOffset-1)
        adjacent.bottom = hits.bottom

    unless adjacent.top?
      adjacent.top = tileSearchHorizontal(grid, tileWidth,tileHeight, box.top-1, box.left, box.right-1)
    unless adjacent.bottom?
      adjacent.bottom = tileSearchHorizontal(grid, tileWidth,tileHeight,Math.ceil(box.bottom+1), box.left, box.right-1)


    # Step 2: apply & restrict horizontal movement
    box.moveX(vx * @dt())

    hits.left = tileSearchVertical(grid, tileWidth,tileHeight,box.left, box.top, box.bottom-1)
    if hits.left.length > 0
      s = hits.left[0]
      box.setX(s.x+s.width - box.leftOffset)
      adjacent.left = hits.left
    else
      hits.right = tileSearchVertical(grid, tileWidth,tileHeight, Math.ceil(box.right), box.top, box.bottom-1)
      if hits.right.length > 0
        console.log "hits.right",hits.right
        s = hits.right[0]
        box.setX(s.x - box.rightOffset-1)
        adjacent.right = hits.right

    unless adjacent.left?
      adjacent.left = tileSearchVertical(grid, tileWidth,tileHeight,box.left-1, box.top, box.bottom-1)
    unless adjacent.right?
      adjacent.right = tileSearchVertical(grid, tileWidth,tileHeight, Math.ceil(box.right+1), box.top, box.bottom-1)
    
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
    hitBoxJS.touchingSomething = hitBoxJS.touching.left or hitBoxJS.touching.right or hitBoxJS.touching.top or hitBoxJS.touching.bottom

    hitBoxJS.adjacent = {}
    hitBoxJS.adjacent.top = adjacent.top.length > 0
    hitBoxJS.adjacent.bottom = adjacent.bottom.length > 0
    hitBoxJS.adjacent.left = adjacent.left.length > 0
    hitBoxJS.adjacent.right = adjacent.right.length > 0

    @updateComp hitBox.merge(hitBoxJS)

    # Update velocity if needed based on running into objects:
    if hitBoxJS.touching.left or hitBoxJS.touching.right
      vx = 0

    if hitBoxJS.touching.top or hitBoxJS.touching.bottom
      vy = 0
    
    @updateComp velocity.set('x',vx).set('y',vy)

module.exports = MapPhysicsSystem

