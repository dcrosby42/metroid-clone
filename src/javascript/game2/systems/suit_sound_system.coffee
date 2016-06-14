BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'


JUMP_SOUND_ID = "jump"
STEP_SOUND_ID = "step2"

JumpSound = Prefab.soundComponent
  soundId: JUMP_SOUND_ID
  volume: 0.5
  playPosition: 0
  timeLimit: 170

RunSound = Prefab.soundComponent
    soundId: STEP_SOUND_ID
    volume: 0.15
    playPosition: 0
    timeLimit: 170
    loop: true

class SuitSoundSystem extends BaseSystem
  @Subscribe: [ T.Suit, T.Motion ]

  process: (r) ->
    [suit,motion] = r.comps

    oracle = motion.motions.oracle()

    @handleEvents r.eid,
      jump: =>
        @_startJumpingSound(r.entity)
    
    if oracle.running()
      @_startRunningSound(r.entity)
    else
      @_stopRunningSound(r.entity)

    # VISUAL POSE #FIXME WHY THE HELL IS THIS HIDING IN THE SOUND SYSTEM???
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
    # console.log "Add jump sound to entity",JumpSound, entity
    entity.addComponent JumpSound.clone()

  _startRunningSound: (entity) ->
    found = false
    entity.each T.Sound, (comp) ->
      if comp.soundId == STEP_SOUND_ID
        found = true

    if !found
      entity.addComponent RunSound.clone()

  _stopRunningSound: (entity) ->
    entity.each T.Sound, (comp) ->
      if comp.soundId == STEP_SOUND_ID
        entity.deleteComponent comp

module.exports = -> new SuitSoundSystem()

