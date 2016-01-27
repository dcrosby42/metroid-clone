Common = require '../../components'
BaseSystem = require '../../../../ecs/base_system'
MotionOracle = require './motion_oracle'

handleEvents = (events,fns) ->
  events.forEach (e) ->
    fns[e.get('name')]?()

class SuitSoundSystem extends BaseSystem
  @Subscribe: [ 'suit', 'motion' ]

  process: ->
    @handleEvents
      jump: =>
        @_startJumpingSound()
    
    mo = new MotionOracle(@getComp('motion'))
    if mo.running()
      @_startRunningSound()
    else
      @_stopRunningSound()

  _startJumpingSound: ->
    @addComp Common.Sound.merge
      soundId: 'jump'
      volume: 0.2
      playPosition: 0
      timeLimit: 170

  _startRunningSound: ->
    s = @getEntityComponents(@eid(), 'sound').find (s) -> 'step2' == s.get('soundId')
    unless s?
      @addComp Common.Sound.merge
        soundId: 'step2'
        volume: 0.04
        playPosition: 0
        timeLimit: 20
        loop: true

  _stopRunningSound: ->
    @getEntityComponents(@eid(), 'sound').forEach (s) =>
      if 'step2' == s.get('soundId')
        @deleteComp s

module.exports = SuitSoundSystem

