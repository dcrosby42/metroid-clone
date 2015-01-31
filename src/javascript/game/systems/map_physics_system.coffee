AnchoredBox = require '../../utils/anchored_box'

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


class MapPhysicsSystem
  constructor: ({@tileGrid, @tileWidth, @tileHeight}) ->

  run: (estore,dt,input) ->
    for velocity in estore.getComponentsOfType('velocity')
      hitBox = estore.getComponent(velocity.eid, 'hit_box')
      position = estore.getComponent(velocity.eid, 'position')
      if hitBox and position
        box = new AnchoredBox(hitBox)
        box.setXY position.x, position.y

        hits =
          left: []
          right: []
          top: []
          bottom: []

        grid = @tileGrid

        # Apply & restrict VERTICAL movement
        box.moveY(velocity.y * dt)

        hits.top = tileSearchHorizontal(grid, @tileWidth,@tileHeight,box.top, box.left, box.right-1)
        if hits.top.length > 0
          s = hits.top[0]
          box.setY(s.y+s.height - box.topOffset)
        else
          hits.bottom = tileSearchHorizontal(grid, @tileWidth,@tileHeight,box.bottom, box.left, box.right-1)
          if hits.bottom.length > 0
            s = hits.bottom[0]
            box.setY(s.y - box.bottomOffset)
          else

        # Step 2: apply & restrict horizontal movement
        box.moveX(velocity.x * dt)

        hits.left = tileSearchVertical(grid, @tileWidth,@tileHeight,box.left, box.top, box.bottom-1)
        if hits.left.length > 0
          s = hits.left[0]
          box.setX(s.x+s.width - box.leftOffset)
        else
          hits.right = tileSearchVertical(grid, @tileWidth,@tileHeight,box.right, box.top, box.bottom-1)
          if hits.right.length > 0
            s = hits.right[0]
            box.setX(s.x - box.rightOffset)
        
        # Update position and hit_box components 
        position.x = box.x
        position.y = box.y
        hitBox.x = box.x # kinda redundant but let's just keep er up2date ok
        hitBox.y = box.y# kinda redundant but let's just keep er up2date ok

        hitBox.touching.left = hits.left.length > 0
        hitBox.touching.right = hits.right.length > 0
        hitBox.touching.top = hits.top.length > 0
        hitBox.touching.bottom = hits.bottom.length > 0

        # Update velocity if needed based on running into objects:
        if hitBox.touching.left or hitBox.touching.right
          velocity.x = 0

        if hitBox.touching.top or hitBox.touching.bottom
          velocity.y = 0


module.exports = MapPhysicsSystem

