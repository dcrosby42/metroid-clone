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
    @_clearStunTimer()
    @_makeHitSound()
    @updateProp 'enemy', 'hp', (hp) => hp - 5  # TODO @getProp('bullet', 'damage')
    if @getProp('enemy', 'hp') > 0
      @_setStunTimer()
    else
      @destroyEntity @eid()
      @_makeSplode()

  wakeUpAction: ->
    @_clearStunTimer()

  _makeHitSound: ->
    @newEntity [
      Common.Sound.merge
        soundId: 'enemy_die1'
        volume: 0.15
        playPosition: 0
        timeLimit: 170
    ]

  _setStunTimer: ->
    timer = Common.Timer.merge
      time: 200
      event: 'stunRecovered'
      name: 'stun'
    @addComponent @eid(), timer

  _clearStunTimer: ->
    @getEntityComponents(@eid(), 'timer', 'name','stun').forEach (comp) =>
      @delete comp

  _makeSplode: ->
    enemyBox = new AnchoredBox(@get('hit_box').toJS())
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

module.exports = EnemyHitSystem

