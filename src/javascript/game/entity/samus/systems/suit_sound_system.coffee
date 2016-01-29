Common = require '../../components'
BaseSystem = require '../../../../ecs/base_system'
SuitMotionOracle = require './suit_motion_oracle'

class SuitSoundSystem extends BaseSystem
  @Subscribe: [ 'suit', 'motion' ]

  process: ->
    oracle = new SuitMotionOracle(@getComp('motion'))

    @handleEvents
      jump: =>
        @_startJumpingSound()
    
    if oracle.running()
      @_startRunningSound()
    else
      @_stopRunningSound()

    # VISUAL POSE
    @setProp 'suit','pose', if oracle.running()
      'running'
    else if oracle.airborn()
      'airborn'
    else
      'standing'
      
  # 
  # Helpers
  #

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

