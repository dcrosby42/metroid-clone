class SkreeVelocity
  run: (estore,dt,input) ->
    for skree in estore.getComponentsOfType('skree')
      if velocity = estore.getComponent skree.eid, 'velocity'
        velocity.x = 0
        switch skree.action
          when 'attack'
            if skree.direction == 'right'
              velocity.x = skree.strafeSpeed
            else if skree.direction == 'left'
              velocity.x = -skree.strafeSpeed





module.exports = SkreeVelocity

