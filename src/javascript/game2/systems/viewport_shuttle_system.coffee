BaseSystem = require '../../ecs2/base_system'
Prefab = require "../prefab"
C = require '../../components'
T = C.Types
MathUtils = require '../../utils/math_utils'

class ViewportShuttleSystem extends BaseSystem
  @Subscribe: [
    [T.ViewportShuttle, {type: T.Position, name: 'position'}, {type:T.Position, name:'destination'}]
    [T.Viewport, T.Position]
  ]

  process: (shuttleR,viewportR) ->
    [shuttle, shuttlePosition, shuttleDest] = shuttleR.comps
    [viewport, viewportPosition] = viewportR.comps
    
    shuttleX = shuttlePosition.x
    shuttleY = shuttlePosition.y

    destX = shuttleDest.x
    destY = shuttleDest.y

    if shuttleX == destX
      # nothing
    else
      dx = (128 / 1000) * @input.get('dt') # 128px or half screen (horiz) per sec
      if shuttleX < destX
        # shuttle right
        shuttleX = MathUtils.clamp(shuttleX+dx, shuttleX, destX)
      else
        # shuttle left
        shuttleX = MathUtils.clamp(shuttleX-dx, destX, shuttleX)

    if shuttleY == destY
      # nothing
    else
      dy = (120 / 1000) * @input.get('dt') # 120px, or half screen (vertically) per sec
      if shuttleY < destY
        # shuttle down
        shuttleY = MathUtils.clamp(shuttleY+dy, shuttleY, destY)
      else
        # shuttle up
        shuttleY = MathUtils.clamp(shuttleY-dy, destY, shuttleY)

    # jump viewport to shuttle:
    viewportPosition.x = shuttleX
    viewportPosition.y = shuttleY
    
    if shuttleX == destX and shuttleY == destY
      # AT DESTINATION
      # Resume targeting the previous targeted entity:
      target = @estore.getEntity(shuttle.thenTarget)
      target.addComponent Prefab.tag('viewport_target')

      # Remove the shuttle entity
      shuttleR.entity.destroy()

    else
      # Just update the shuttle position
      shuttlePosition.x = shuttleX
      shuttlePosition.y = shuttleY

module.exports = -> new ViewportShuttleSystem()

