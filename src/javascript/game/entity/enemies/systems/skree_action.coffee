Common = require './../../components'

class SkreeAction
  run: (estore,dt,input) ->
    for skree in estore.getComponentsOfType('skree')
      position = estore.getComponent skree.eid, 'position'

      switch skree.action
        when 'sleep'
          for samus in estore.getComponentsOfType('samus')
            samusPos = estore.getComponent samus.eid, 'position'
            if Math.abs(position.x - samusPos.x) <= skree.triggerRange
              skree.action = 'attack'
              skree.agro_eid = samus.eid
              estore.addComponent(
                skree.eid
                new Common.Gravity
                  max: 300/1000
                  accel: (200/1000)/10
              )
        when 'attack'
          hitBox = estore.getComponent skree.eid, 'hit_box'
          if hitBox.touching.bottom
            skree.action = 'countdown'
            skree.direction = 'neither'
            skree.countdown = 1000
          else
            samusPos = estore.getComponent skree.agro_eid, 'position'
            if samusPos.x < position.x
              skree.direction = 'left'
            else if samusPos.x > position.x
              skree.direction = 'right'
            else
              skree.direction = 'neither'
        when 'countdown'
          skree.countdown -= dt
          if skree.countdown < 0
            skree.action = 'explode'

        when 'explode'
          estore.destroyEntity skree.eid
          
module.exports = SkreeAction

