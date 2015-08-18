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

    if orientation == 'up'
      @setProp 'velocity', 'y', 0.04
      if hitBox.getIn(['adjacent','bottom'])
        @setProp 'velocity', 'x', -0.04
      else
        @setProp 'velocity', 'x', 0.01

    if orientation == 'left'
      @setProp 'velocity', 'x', 0.04
      if hitBox.getIn(['adjacent','right'])
        @setProp 'velocity', 'y', 0.04
      else
        @setProp 'velocity', 'y', -0.01

    if orientation == 'down'
      @setProp 'velocity', 'y', -0.04
      if hitBox.getIn(['adjacent','top'])
        @setProp 'velocity', 'x', 0.04
      else
        @setProp 'velocity', 'x', -0.01

    if orientation == 'right'
      @setProp 'velocity', 'x', -0.04
      if hitBox.getIn(['adjacent','left'])
        @setProp 'velocity', 'y', -0.04
      else
        @setProp 'velocity', 'y', 0.01

    if hitBox.getIn(['adjacent','right'])
      @setProp('zoomer', 'orientation', 'left')
    else if hitBox.getIn(['adjacent','top'])
      @setProp('zoomer', 'orientation', 'down')
    else if hitBox.getIn(['adjacent','left'])
      @setProp('zoomer', 'orientation', 'right')
    else if hitBox.getIn(['adjacent','bottom'])
      @setProp('zoomer', 'orientation', 'up')
      
    # TODO: animation system?
    visual = @getComp 'visual'
    newOrient = @getProp('zoomer','orientation')
    newState = "crawl-#{newOrient}"
    priorState = visual.get('state')
    if newState != priorState
      @updateComp visual.set('state',newState).set('time',0)

  process_2: ->
    zoomer = @getComp('zoomer')
    hitBox = @getComp('hit_box')
    velocity = @getComp('velocity')

    orientation = zoomer.get('orientation')

    if hitBox.getIn(['adjacent','bottom'])
      if orientation == 'up'
        @updateComp velocity.set('x', -0.04)
        @updateComp zoomer.set('wasTouching', 'bottom')
        # @updateComp velocity.set('x', 0)
      # else
      #   @updateComp zoomer.set('orientation', LeftRot[orientation])
    else if hitBox.getIn(['adjacent','right'])
      if orientation == 'left'
        @updateComp velocity.set('y', 0.04)
        @updateComp zoomer.set('wasTouching', 'right')

    else if hitBox.getIn(['adjacent','top'])
      if orientation == 'down'
        @updateComp velocity.set('x', 0.04)
        @updateComp zoomer.set('wasTouching', 'top')

    else if hitBox.getIn(['adjacent','left'])
      if orientation == 'right'
        @updateComp velocity.set('y', -0.04)
        @updateComp zoomer.set('wasTouching', 'left')

    else
      wasTouching = @getProp('zoomer','wasTouching')
      if wasTouching == 'bottom'
        @setProp('zoomer', 'orientation', LeftRot[orientation])
        @setProp('zoomer', 'wasTouching', 'nothing')
        @updateProp('position', 'x', (x) -> x-1)
        @updateProp('position', 'y', (y) -> y+2)
      else if wasTouching == 'right'
        @setProp('zoomer', 'orientation', LeftRot[orientation])
        @setProp('zoomer', 'wasTouching', 'nothing')
        @updateProp('position', 'x', (x) -> x+3)
        @updateProp('position', 'y', (y) -> y)
      else if wasTouching == 'top'
        @setProp('zoomer', 'orientation', LeftRot[orientation])
        @setProp('zoomer', 'wasTouching', 'nothing')
        @updateProp('position', 'x', (x) -> x-0.5)
        @updateProp('position', 'y', (y) -> y-2)
      else if wasTouching == 'left'
        @setProp('zoomer', 'orientation', LeftRot[orientation])
        @setProp('zoomer', 'wasTouching', 'nothing')
        @updateProp('position', 'x', (x) -> x-1)
        # @updateProp('position', 'y', (y) -> y-2)
      else if wasTouching == 'nothing'
        if orientation == 'left'
          console.log "left and floating"


      @updateComp velocity.set('x', 0).set('y',0)


    # TODO: animation system?
    visual = @getComp 'visual'
    newOrient = @getProp('zoomer','orientation')
    newState = "crawl-#{newOrient}"
    priorState = visual.get('state')
    if newState != priorState
      @updateComp visual.set('state',newState).set('time',0)





module.exports = ZoomerCrawlSystem

