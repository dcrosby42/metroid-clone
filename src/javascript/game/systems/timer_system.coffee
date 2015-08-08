BaseSystem = require '../../ecs/base_system'

class TimerSystem extends BaseSystem
  @Subscribe: ['timer']

  process: ->
    timer = @getComp('timer').update('time', (t) => t - @dt())
    if timer.get('time') > 0
      @updateComp timer
    else
      @publishEvent timer.get('event')
      @deleteComp timer

module.exports = TimerSystem

