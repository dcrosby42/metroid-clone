# AnchoredBox = require '../../utils/anchored_box'
BaseSystem = require '../../ecs/base_system'

# tileSearchVertical = (grid, tw,th, x, topY, bottomY) ->
#   hits = []
#   c = Math.floor(x/tw)
#   for r in [Math.floor(topY/th)..Math.floor(bottomY/th)]
#     row = grid[r]
#     if row?
#       hit = grid[r][c]
#       if hit?
#         hits.push hit
#   hits
#
# tileSearchHorizontal = (grid, tw,th, y, leftX, rightX) ->
#   hits = []
#   r = Math.floor(y/th)
#   row = grid[r]
#   if row?
#     for c in [Math.floor(leftX/tw)..Math.floor(rightX/tw)]
#       hit = grid[r][c]
#       if hit?
#         hits.push hit
#   hits

class MapGhostSystem extends BaseSystem
  @Subscribe: ['map_ghost', 'hit_box', 'velocity','position']

  process: ->
    newPosition = @getComp('position')
      .update('x', (x) => x + @getProp('velocity','x') * @dt())
      .update('y', (y) => y + @getProp('velocity','y') * @dt())

    newHitBox = @getComp('hit_box')
      .set('x', newPosition.get('x'))
      .set('y', newPosition.get('y'))

    @updateComp newPosition
    @updateComp newHitBox

module.exports = MapGhostSystem

