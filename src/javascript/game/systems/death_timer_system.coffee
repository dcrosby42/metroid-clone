
# class DeathTimerSystem
#   run: (estore, dt, input) ->
#     timers = estore.getComponentsOfType('death_timer')
#     for timer in timers
#       timer.time -= dt
#       if timer.time < 0
#         estore.destroyEntity timer.eid

module.exports =
  config:
    filters: ['death_timer']

  update: (comps,input,u) ->
    timer = comps.get('death_timer')
    dt = input.get('dt')
    currentTime = timer.get('time') - dt
    if currentTime < 0
      u.destroyEntity timer.get('eid')
    else
      u.update timer.set 'time', currentTime
