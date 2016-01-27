BaseSystem = require '../../../../ecs/base_system'
Immutable = require 'immutable'

class MotionSystem extends BaseSystem
  @Subscribe: ['motion', 'velocity', 'hit_box']

  process: ->
    velocity = @getComp('velocity')
    hitBox = @getComp('hit_box')

    motions = []

    if velocity.get('y') < 0
      motions.push('rising')
    else if velocity.get('y') > 0
      motions.push('falling')
    else
      motions.push('yStill')

    if hitBox.getIn(['touching','bottom'])
      motions.push('touching')
      motions.push('touchingBottom')
    if hitBox.getIn(['touching','top'])
      motions.push('touching')
      motions.push('touchingTop')


    if velocity.get('x') > 0
      motions.push('movingSideways')
      motions.push('movingRight')
    else if velocity.get('x') < 0
      motions.push('movingSideways')
      motions.push('movingLeft')
    else
      motions.push('xStill')

    @setProp 'motion', 'states', Immutable.Set(motions)

module.exports = MotionSystem

