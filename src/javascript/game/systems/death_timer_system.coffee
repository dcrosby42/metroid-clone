
class DeathTimerSystem
  run: (estore, dt, input) ->
    timers = estore.getComponentsOfType('death_timer')
    for timer in timers
      timer.time -= dt
      if timer.time < 0
        estore.destroyEntity timer.eid

module.exports = DeathTimerSystem

