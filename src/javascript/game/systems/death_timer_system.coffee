BaseSystem = require '../../ecs/base_system'

class DeathTimerSystem extends BaseSystem
  @Subscribe: ['death_timer']

  process: ->
    @updateProp 'death_timer', 'time', (t) => t - @dt()
    if @getProp('death_timer', 'time') < 0
      @destroyEntity()

module.exports = DeathTimerSystem
