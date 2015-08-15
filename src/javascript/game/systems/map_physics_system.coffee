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

    # Apply & restrict VERTICAL movement
    box.moveY(vy * @dt())

    hits.top = tileSearchHorizontal(grid, tileWidth,tileHeight,box.top, box.left, box.right-1)
    if hits.top.length > 0
      s = hits.top[0]
      box.setY(s.y+s.height - box.topOffset)
    else
      hits.bottom = tileSearchHorizontal(grid, tileWidth,tileHeight,box.bottom, box.left, box.right-1)
      # console.log "tileSearchHorizontal(grid, tileWidth,tileHeight,box.bottom, box.left, box.right-1)", tileWidth,tileHeight,box.bottom, box.left, box.right-1
      if hits.bottom.length > 0
        s = hits.bottom[0]
        box.setY(s.y - box.bottomOffset)

    # Step 2: apply & restrict horizontal movement
    box.moveX(vx * @dt())

    hits.left = tileSearchVertical(grid, tileWidth,tileHeight,box.left, box.top, box.bottom-1)
    if hits.left.length > 0
      s = hits.left[0]
      box.setX(s.x+s.width - box.leftOffset)
    else
      hits.right = tileSearchVertical(grid, tileWidth,tileHeight,box.right, box.top, box.bottom-1)
      if hits.right.length > 0
        s = hits.right[0]
        box.setX(s.x - box.rightOffset)
    
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

    @updateComp hitBox.merge(hitBoxJS)

    # Update velocity if needed based on running into objects:
    if hitBoxJS.touching.left or hitBoxJS.touching.right
      vx = 0

    if hitBoxJS.touching.top or hitBoxJS.touching.bottom
      vy = 0
    
    @updateComp velocity.set('x',vx).set('y',vy)

module.exports = MapPhysicsSystem

