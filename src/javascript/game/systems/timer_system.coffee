BaseSystem = require '../../ecs/base_system'

class TimerSystem extends BaseSystem
  @Subscribe: ['timer']

  process: ->
    timer = @get('timer').update('time', (t) => t - @dt())
    if timer.get('time') > 0
      @update timer
    else
      @publishEvent timer.get('eid'), timer.get('event')
      @delete timer

module.exports = TimerSystem

