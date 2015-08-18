Immutable = require 'immutable'
BaseSystem = require '../../../../ecs/base_system'

class ZoomerControllerSystem extends BaseSystem
  @Subscribe: ['zoomer','controller','position','velocity']

  process: ->
    zoomer = @getComp('zoomer')
    ctrl = @getProp 'controller', 'states'
    position = @getComp('position')

    m = 0.05
    if ctrl.get('mod1')
      m = 0.01

    dx = dy = 0
    if ctrl.get('moveLeft')
      dx = -m
    else if ctrl.get('moveRight')
      dx = m

    if ctrl.get('moveUp')
      dy = -m
    else if ctrl.get('moveDown')
      dy = m

    @updateProp 'velocity', 'x', (x) => dx 
    @updateProp 'velocity', 'y', (y) => dy 

    if ctrl.get('toggleCrawlPressed')
      console.log "HEY"
      if crawl = @getEntityComponent(@eid(), 'crawl')
        @deleteComp crawl
      else
        @addComp Immutable.Map(type: 'crawl')

    if ctrl.get('toggleCrawlDirPressed')
      @updateProp 'zoomer', 'crawlDir', (dir) ->
        if dir == 'forward' then 'backward' else 'forward'


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

