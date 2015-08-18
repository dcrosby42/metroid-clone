# StateMachineSystem = require '../../../../ecs/state_machine_system'
BaseSystem = require '../../../../ecs/base_system'

LeftRot = {
  up: 'left'
  left: 'down'
  down: 'right'
  right: 'up'
}

# class ZoomerCrawlSystem extends StateMachineSystem
class ZoomerCrawlSystem extends BaseSystem
  @Subscribe: ['zoomer','crawl','hit_box','velocity','position','visual']

  # @StateMachine:
  #   componentProperty: ['zoomer','rotation']
  #
  process: ->
    zoomer = @getComp('zoomer')
    hitBox = @getComp('hit_box')
    velocity = @getComp('velocity')

    orientation = zoomer.get('orientation')

    adjRight = hitBox.getIn(['adjacent','right'])
    adjLeft = hitBox.getIn(['adjacent','left'])
    adjTop = hitBox.getIn(['adjacent','top'])
    adjBottom = hitBox.getIn(['adjacent','bottom'])

    fakeGrav = 0.04
    crawlSpeed = 0.04
    floorHug = 0.01

    if orientation == 'up'
      @setProp 'velocity', 'y', fakeGrav
      if adjBottom
        @setProp 'velocity', 'x', -crawlSpeed
      else
        @setProp 'velocity', 'x', floorHug

    if orientation == 'left'
      @setProp 'velocity', 'x', fakeGrav
      if adjRight
        @setProp 'velocity', 'y', crawlSpeed
      else
        @setProp 'velocity', 'y', -floorHug

    if orientation == 'down'
      @setProp 'velocity', 'y', -fakeGrav
      if adjTop
        @setProp 'velocity', 'x', crawlSpeed
      else
        @setProp 'velocity', 'x', -floorHug

    if orientation == 'right'
      @setProp 'velocity', 'x', -fakeGrav
      if adjLeft
        @setProp 'velocity', 'y', -crawlSpeed
      else
        @setProp 'velocity', 'y', floorHug

    if adjRight and !adjBottom
      orientation = 'left'
    else if adjTop
      orientation = 'down'
    else if adjLeft
      orientation = 'right'
    else if adjBottom
      orientation = 'up'

    @setProp('zoomer', 'orientation', orientation)
      
    # TODO: animation system?
    visual = @getComp 'visual'
    newState = "crawl-#{orientation}"
    priorState = visual.get('state')
    if newState != priorState
      @updateComp visual.set('state',newState).set('time',0)




module.exports = ZoomerCrawlSystem

