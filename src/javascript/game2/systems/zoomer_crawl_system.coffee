# StateMachineSystem = require '../../../../ecs/state_machine_system'
BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

class ZoomerCrawlSystem extends BaseSystem
  @Subscribe: [T.Zoomer,T.HitBox,T.Velocity,T.Animation]

  process: (r) ->
    [zoomer,hitBox,velocity,animation] = r.comps
    orientation = zoomer.orientation
    crawlDir = zoomer.crawlDir

    adjRight = hitBox.adjacent.right
    adjLeft = hitBox.adjacent.left
    adjTop = hitBox.adjacent.top
    adjBottom = hitBox.adjacent.bottom

    fakeGrav = 0.04
    crawlSpeed = 0.04
    floorHug = 0.01
    if crawlDir == 'backward'
      crawlSpeed = -crawlSpeed
      floorHug = -floorHug

    if orientation == 'up'
      velocity.y = fakeGrav
      if adjBottom
        velocity.x = -crawlSpeed
      else
        velocity.x = floorHug

    if orientation == 'left'
      velocity.x = fakeGrav
      if adjRight
        velocity.y = crawlSpeed
      else
        velocity.y = -floorHug

    if orientation == 'down'
      velocity.y = -fakeGrav
      if adjTop
        velocity.x = crawlSpeed
      else
        velocity.x = -floorHug

    if orientation == 'right'
      velocity.x = -fakeGrav
      if adjLeft
        velocity.y = -crawlSpeed
      else
        velocity.y = floorHug

    if crawlDir == 'forward'
      if adjRight and !adjBottom
        orientation = 'left'
      else if adjTop
        orientation = 'down'
      else if adjLeft
        orientation = 'right'
      else if adjBottom
        orientation = 'up'
    else
      if adjBottom and !adjRight
        orientation = 'up'
      else if adjLeft
        orientation = 'right'
      else if adjTop
        orientation = 'down'
      else if adjRight
        orientation = 'left'

    zoomer.orientation = orientation
      
    # TODO: separate animation system?
    priorState = animation.state
    newState = "crawl-#{orientation}"
    if newState != priorState
      animation.state = newState
      animation.time = 0

module.exports = -> new ZoomerCrawlSystem()

