# Immutable = require 'immutable'
BaseSystem = require '../../ecs/base_system'
MathUtils = require '../../utils/math_utils'
Common = require '../entity/components'

class ViewportShuttleSystem extends BaseSystem
  @Subscribe: [
    ['viewport_shuttle', 'position', 'destination']
    ['viewport', 'position']
  ]

  process: ->
    shuttlePosition = @getComp('viewport_shuttle-position')
    shuttleX = shuttlePosition.get('x')
    shuttleY = shuttlePosition.get('y')

    shuttleDest = @getComp('viewport_shuttle-destination')
    destX = shuttleDest.get('x')
    destY = shuttleDest.get('y')

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
        shuttleY = MathUtils.clamp(shuttleY+dY, shuttleY, destY)
      else
        # shuttle up
        shuttleY = MathUtils.clamp(shuttleY-dy, destY, shuttleY)


    # jump viewport to shuttle:
    viewportPosition = @getComp('viewport-position')
    @updateComp viewportPosition.set('x',shuttleX).set('y',shuttleY)
    
    if shuttleX == destX and shuttleY == destY
      # AT DESTINATION
      shuttle = @getComp('viewport_shuttle') # destArea, thenTarget
      # Resume targeting the previous targeted entity:
      targetEid = shuttle.get('thenTarget')
      @addEntityComp targetEid, Common.ViewportTarget
      # Remove the shuttle entity
      @destroyEntity shuttle.get('eid')
    else
      @updateComp shuttlePosition.set('x',shuttleX).set('y',shuttleY)

module.exports = ViewportShuttleSystem

