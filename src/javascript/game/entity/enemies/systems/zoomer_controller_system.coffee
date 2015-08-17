Immutable = require 'immutable'
BaseSystem = require '../../../../ecs/base_system'

class ZoomerControllerSystem extends BaseSystem
  @Subscribe: ['zoomer','controller','position','velocity']

  process: ->
    zoomer = @getComp('zoomer')
    ctrl = @getProp 'controller', 'states'
    position = @getComp('position')

    m = 0.05
    if ctrl.get('action1')
      m = 0.01

    dx = dy = 0
    if ctrl.get('left')
      dx = -m
    else if ctrl.get('right')
      dx = m

    if ctrl.get('up')
      dy = -m
    else if ctrl.get('down')
      dy = m

    @updateProp 'velocity', 'x', (x) => dx 
    @updateProp 'velocity', 'y', (y) => dy 

    if ctrl.get('action2Pressed')
      if crawl = @getEntityComponent(@eid(), 'crawl')
        @deleteComp crawl
      else
        @addComp Immutable.Map(type: 'crawl')

    # mx = 1
    # my = 1
    # x = position.get('x')
    # y = position.get('y')
    # if ctrl.get('left')
    #   x -= mx
    # else if ctrl.get('right')
    #   x += mx
    #
    # if ctrl.get('up')
    #   y -= my
    # else if ctrl.get('down')
    #   y += my
    #
    # @updateComp position.set('x',x).set('y',y)

module.exports = ZoomerControllerSystem

