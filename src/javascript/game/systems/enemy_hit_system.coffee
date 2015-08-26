Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
StateMachineSystem = require '../../ecs/state_machine_system'

class EnemyHitSystem extends StateMachineSystem
  @Subscribe: ['enemy', 'hit_box', 'animation']

  @StateMachine:
    componentProperty: ['enemy','hitState']
    start: 'normal'
    states:
      normal:
        events:
          shot:
            action: 'damage'
            nextState: 'stunned'
      stunned:
        events:
          shot:
            action: 'damage'
            nextState: 'stunned'
          stunRecovered:
            action: 'wakeUp'
            nextState: 'normal'

  damageAction: (damageVal) ->
    @_makeHitSound()
    @updateProp 'enemy', 'hp', (hp) => hp - damageVal
    if @getProp('enemy', 'hp') > 0
      @_stun()
    else
      @destroyEntity()
      @_makeSplode()

  wakeUpAction: ->
    @_unStun()

  #
  # HELPERS:
  #

  _makeHitSound: ->
    @newEntity [
      Common.Sound.merge
        soundId: 'enemy_die1'
        volume: 0.15
        playPosition: 0
        timeLimit: 170
    ]

  _stun: ->
    @_clearStunTimer()
    @_setStunTimer()
    
    @_swapOutAnimation()
    @_swapOutVelocity()
    
    # @publishEvent @eid(), 'stunned' # for other systems

  _setStunTimer: ->
    @addComp Common.Timer.merge
      time: 200
      event: 'stunRecovered'
      name: 'stun'

  _unStun: ->
    @_clearStunTimer()
    @_swapInAnimation()
    @_swapInVelocity()

  _clearStunTimer: ->
    timer = @getEntityComponent(@eid(), 'timer', 'name','stun')
    if timer?
      @deleteComp timer

  _makeSplode: ->
    enemyBox = new AnchoredBox(@getComp('hit_box').toJS())
    @newEntity [
      Common.Animation.merge
        layer: 'creatures'
        spriteName: 'creature_explosion'
        state: 'explode'
      Common.Position.merge
        x: enemyBox.centerX
        y: enemyBox.centerY
      Common.DeathTimer.merge
        time: 3 * (1000/20) # the splode anim lasts three or four twentieths of a second
    ]

  _swapOutAnimation: ->
    animation = @getComp('animation')
    stashedAnimation = animation
      .set('type', 'STASHED-animation')
    @addComp stashedAnimation
    
    stunnedAnimation = animation
      .update('state', (s) -> "stunned-#{s}")
      .set('paused',true)
    @addComp stunnedAnimation
    
    @deleteComp animation

  _swapInAnimation: ->
    if stashedAnimation = @getEntityComponent @eid(), "STASHED-animation"
      stunnedAnimation = @getComp('animation')
      restoredAnimation = stashedAnimation.set('type','animation')
      @addComp restoredAnimation
      @deleteComp stunnedAnimation
      @deleteComp stashedAnimation

  _swapOutVelocity: ->
    if velocity = @getEntityComponent @eid(), 'velocity'
      stashed = velocity.set('type', 'STASHED-velocity')
      @addComp stashed
      @deleteComp velocity
    
  _swapInVelocity: ->
    if stashed = @getEntityComponent @eid(), "STASHED-velocity"
      @deleteComp stashed
      restored = stashed.set('type','velocity')
      @addComp restored

module.exports = EnemyHitSystem

