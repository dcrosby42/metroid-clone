BaseSystem = require '../../ecs2/base_system'
Prefab = require "../prefab"
C = require '../../components'
T = C.Types
MathUtils = require '../../utils/math_utils'

class ViewportShuttleSystem extends BaseSystem
  # @subscribe: [
  #   ['viewport_shuttle', 'position', 'destination']
  #   ['viewport', 'position']
  # ]
  @Subscribe: [
    [T.ViewportShuttle, {type: T.Position, name: 'position'}, {type:T.Position, name:'destination'}]
    [T.Viewport, T.Position]
  ]

  process: (shuttleR,viewportR) ->
    [shuttle, shuttlePosition, shuttleDest] = shuttleR.comps
    shuttleEnt = shuttleR.entity
    [viewport, viewportPosition] = viewportR.comps
    
    # shuttlePosition = @getComp('viewport_shuttle-position')
    shuttleX = shuttlePosition.x
    shuttleY = shuttlePosition.y

    # shuttleDest = @getComp('viewport_shuttle-destination')
    destX = shuttleDest.x
    destY = shuttleDest.y

    if shuttleX == destX
      # nothing
    else
      dx = (128 / 1000) * @input.get('dt')
      if shuttleX < destX
        # shuttle right
        shuttleX = MathUtils.clamp(shuttleX+dx, shuttleX, destX)
      else
        # shuttle left
        shuttleX = MathUtils.clamp(shuttleX-dx, destX, shuttleX)

    if shuttleY == destY
      # nothing
    else
      dy = (120 / 1000) * @input.get('dt')
      if shuttleY < destY
        # shuttle down
        shuttleY = MathUtils.clamp(shuttleY+dy, shuttleY, destY)
      else
        # shuttle up
        shuttleY = MathUtils.clamp(shuttleY-dy, destY, shuttleY)


    # jump viewport to shuttle:
    # viewportPosition = @getComp('viewport-position')
    viewportPosition.x = shuttleX
    viewportPosition.y = shuttleY
    # @updateComp viewportPosition.set('x',shuttleX).set('y',shuttleY)
    
    if shuttleX == destX and shuttleY == destY
      # AT DESTINATION
      # shuttle = @getComp('viewport_shuttle') # destArea, thenTarget
      # Resume targeting the previous targeted entity:
      target = @estore.getEntity(shuttle.thenTarget)
      target.addComponent Prefab.tag('viewport_target')

      # Remove the shuttle entity
      @estore.deleteEntityByEid(shuttleR.eid)

      # @destroyEntity shuttle.get('eid')
    else
      shuttlePosition.x = shuttleX
      shuttlePosition.y = shuttleY
      # @updateComp shuttlePosition.set('x',shuttleX).set('y',shuttleY)

module.exports = -> new ViewportShuttleSystem()

