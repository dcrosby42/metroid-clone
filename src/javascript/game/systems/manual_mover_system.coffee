
class ManualMoverSystem
  constructor: ({@componentType}) ->

  run: (estore,dt,input) ->
    xStep = 4
    yStep = 4
    for hitBox in estore.getComponentsOfType(@componentType)
      if controller = estore.getComponent(hitBox.eid, 'controller')
        ctrl = controller.states
        if ctrl.up
          hitBox.y -= yStep
        if ctrl.down
          hitBox.y += yStep
        if ctrl.left
          hitBox.x -= xStep
        if ctrl.right
          hitBox.x += xStep


module.exports = ManualMoverSystem

