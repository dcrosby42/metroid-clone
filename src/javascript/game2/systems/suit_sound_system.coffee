BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

STEP_SOUND_ID = "step2"

class SuitSoundSystem extends BaseSystem
  @Subscribe: [ T.Suit, T.Motion ]

  process: (r) ->
    [suit,motion] = r.comps

    # oracle = new SuitMotionOracle(@getComp('motion'))
    oracle = motion.motions.oracle()

    @handleEvents
      jump: =>
        @_startJumpingSound(r.entity)
    
    if oracle.running()
      @_startRunningSound(r.entity)
    else
      @_stopRunningSound(r.entity)

    # VISUAL POSE #FIXME WHY THE HELL IS THIS HIDING IN THE SOUND SYSTEM???
    # @setProp 'suit','pose', if oracle.running()
    suit.pose = if oracle.running()
      'running'
    else if oracle.airborn()
      'airborn'
    else
      'standing'
      
  # 
  # Helpers
  #

  _startJumpingSound: (entity) ->
    # entity.addComponent Prefab.sound
      # soundId: 'jump'
      # volume: 0.5
      # playPosition: 0
      # timeLimit: 170

  _startRunningSound: (entity) ->
    # found = false
    # entity.each T.Sound, (comp) ->
    #   if comp.soundId == STEP_SOUND_ID
    #     found = true
    # return if found

    # entity.addComponent Prefab.sound
  #     soundId: STEP_SOUND_ID
  #     # volume: 1
  #     volume: 0.15
  #     playPosition: 0
  #     timeLimit: 170
  #     loop: true

  _stopRunningSound: (entity) ->
    # entity.each T.Sound, (comp) ->
    #   if comp.soundId == STEP_SOUND_ID
    #     entity.deleteComponent comp

module.exports = -> new SuitSoundSystem()

