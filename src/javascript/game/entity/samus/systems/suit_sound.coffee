Common = require '../../components'
BaseSystem = require '../../../../ecs/base_system'
SuitMotionOracle = require './suit_motion_oracle'

STEP_SOUND_ID = "step2"

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
      volume: 0.5
      playPosition: 0
      timeLimit: 170

  _startRunningSound: ->
    s = @getEntityComponents(@eid(), 'sound').find (s) -> STEP_SOUND_ID == s.get('soundId')
    unless s?
      @addComp Common.Sound.merge
        soundId: STEP_SOUND_ID
        # volume: 1
        volume: 0.15
        playPosition: 0
        timeLimit: 170
        loop: true

  _stopRunningSound: ->
    @getEntityComponents(@eid(), 'sound').forEach (s) =>
      if STEP_SOUND_ID == s.get('soundId')
        @deleteComp s

module.exports = SuitSoundSystem

