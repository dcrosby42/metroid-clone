Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'

module.exports =
  config:
    filters: [ 'bullet', 'hit_box' ]

  update: (comps,input,u) ->
    hitBox = comps.get('hit_box')
    if hitBox.get('touchingSomething')
      eid = hitBox.get('eid')
      u.updateEntityComponent eid, 'visual', state: 'splode'
      u.updateEntityComponent eid, 'velocity', x:0, y:0
      u.updateEntityComponent eid, 'death_timer', time: 3*(1000/60)
      u.delete hitBox
