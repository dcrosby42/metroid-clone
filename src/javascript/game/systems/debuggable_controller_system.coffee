Immutable = require 'immutable'
BaseSystem = require '../../ecs/base_system'

class DebuggableControllerSystem extends BaseSystem
  @Subscribe: ['debuggable','controller','position']

  process: ->

    ctrl = @getProp 'controller', 'states'
    position = @getComp('position')

    m = 1
    if ctrl.get('mod1')
      m = 0.5

    dx = dy = 0
    if ctrl.get('moveLeft')
      dx = -m
    else if ctrl.get('moveRight')
      dx = m

    if ctrl.get('moveUp')
      dy = -m
    else if ctrl.get('moveDown')
      dy = m

    @updateProp 'position', 'x', (x) => x + dx
    @updateProp 'position', 'y', (y) => y + dy

module.exports = DebuggableControllerSystem

