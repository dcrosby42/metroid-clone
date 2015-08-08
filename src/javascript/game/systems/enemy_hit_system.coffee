Common = require '../entity/components'
AnchoredBox = require '../../utils/anchored_box'
StateMachineSystem = require '../../ecs/state_machine_system'

class EnemyHitSystem extends StateMachineSystem
  @Subscribe: ['enemy', 'hit_box', 'visual']

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

  damageAction: ->
    console.log "damageAction IN"
    @_makeHitSound()
    @updateProp 'enemy', 'hp', (hp) => hp - 5  # TODO @getProp('bullet', 'damage')
    if @getProp('enemy', 'hp') > 0
      @_stun()
    else
      @destroyEntity @eid()
      @_makeSplode()
    console.log "damageAction OUT"

  wakeUpAction: ->
    console.log "wakeUpAction IN"
    @_unStun()
    console.log "wakeUpAction OUT"

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
    
    @_swapOutVisual()
    @_swapOutVelocity()
    
    # @publishEvent @eid(), 'stunned' # for other systems

  _setStunTimer: ->
    @addComp Common.Timer.merge
      time: 200
      event: 'stunRecovered'
      name: 'stun'

  _unStun: ->
    @_clearStunTimer()
    @_swapInVisual()
    @_swapInVelocity()

  _clearStunTimer: ->
    timer = @getEntityComponent(@eid(), 'timer', 'name','stun')
    if timer?
      @deleteComp timer

  _makeSplode: ->
    enemyBox = new AnchoredBox(@getComp('hit_box').toJS())
    @newEntity [
      Common.Visual.merge
        layer: 'creatures'
        spriteName: 'creature_explosion'
        state: 'explode'
      Common.Position.merge
        x: enemyBox.left + (enemyBox.width/2)
        y: enemyBox.top + (enemyBox.height/2)
      Common.DeathTimer.merge
        time: 3 * (1000/20) # the splode anim lasts three or four twentieths of a second
    ]

  _swapOutVisual: ->
    visual = @getComp('visual')
    stashedVisual = visual
      .set('type', 'STASHED-visual')
    @addComp stashedVisual
    
    stunnedVisual = visual
      .update('state', (s) -> "stunned-#{s}")
      .set('paused',true)
    @addComp stunnedVisual
    
    @deleteComp visual

  _swapInVisual: ->
    if stashedVisual = @getEntityComponent @eid(), "STASHED-visual"
      stunnedVisual = @getComp('visual')
      restoredVisual = stashedVisual.set('type','visual')
      @addComp restoredVisual
      @deleteComp stunnedVisual
      @deleteComp stashedVisual

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
