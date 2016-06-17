StateMachineSystem = require '../../ecs2/state_machine_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'

AnchoredBox = require '../../utils/anchored_box'
Rng = require '../../utils/park_miller_rng'
# Items = require '../entity/items'
# StateMachineSystem = require '../../ecs/state_machine_system'

class EnemyHitSystem extends StateMachineSystem
  @Subscribe: [[T.Enemy, T.HitBox, T.Animation ], [T.Rng]]

  @StateMachine:
    componentProperty: [0,'hitState']
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
    [enemy,hitBox,animation] = @comps
    enemy.hp -= damageVal
    if enemy.hp > 0
      @_stun()
    else
      @_dropSomething()
      @entity.destroy()
      @_makeSplode()

  wakeUpAction: ->
    @_unStun()

  #
  # HELPERS:
  #

  _makeHitSound: ->
    @estore.createEntity Prefab.sound
      soundId: 'enemy_die1'
      volume: 0.4
      playPosition: 0
      timeLimit: 170

  _stun: ->
    @_clearStunTimer()
    @_setStunTimer()
    
    @_swapOutAnimation()
    @_swapOutVelocity()
    
  _setStunTimer: ->
    @entity.addComponent Prefab.timerComponent
      time: 200
      eventName: 'stunRecovered'
      name: 'stun'

  _unStun: ->
    @_clearStunTimer()
    @_swapInAnimation()
    @_swapInVelocity()

  _clearStunTimer: ->
    @entity.each T.Timer, (timer) ->
      if timer.name == 'stun'
        @entity.deleteComponent timer

  _makeSplode: ->
    [enemy,hitBox,animation] = @comps
    enemyBox = new AnchoredBox(hitBox)
    @estore.createEntity Prefab.enemy('creatureExplosion', {
      position:
        x: enemyBox.centerX
        y: enemyBox.centerY
    })

  _swapOutAnimation: ->
    [enemy,hitBox,animation] = @comps

    newAnim = animation.clone()

    stashComponent @entity, 'anim', animation

    newAnim.state = "stunned-#{animation.state}"
    newAnim.paused = true
    @entity.addComponent newAnim

  _swapInAnimation: ->
    [enemy,hitBox,animation] = @comps

    @entity.deleteComponent animation

    unstashComponent @entity, 'anim'

  _swapOutVelocity: ->
    if velocity = @entity.get T.Velocity
      stashComponent @entity, 'vel', velocity
    
  _swapInVelocity: ->
    unstashComponent @entity, 'vel'

  _dropSomething: ->
    [enemy,hitBox,animation] = @rList[0].comps
    [rng] = @rList[1].comps

    [n, rng.state] = Rng.nextInt(rng.state,0,1)
    if (n == 1)
      box = new AnchoredBox(hitBox)
      @estore.createEntity Prefab.drop(
        pickup:
          itemType: 'health_drop'
        position:
          x: box.centerX
          y: box.centerY
      )

    # [enemy,hitBox,animation] = @comps
    # if @_randBool()
    #   box = new AnchoredBox(hitBox)
    #   @estore.createEntity Prefab.healthDrop
    #     position:
    #       x: box.centerX
    #       y: box.centerY


  _randBool: ->
  #
  # _withRng: (name,fn) ->
  #   eid = @firstEntityNamed('mainRandom')
  #   rngComp = @getEntityComponent eid, 'rng'
  #   g = rngComp.get('state')
  #   [x,g1] = fn(g)
  #   @updateComp rngComp.set('state',g1)
  #   return x

#
# TODO: move these somewhere more accessible :
#
stashComponent = (entity, name, comp) ->
  stashed = C.buildCompForType T.Stashed, stashed: comp.clone(), name: name
  entity.deleteComponent comp
  entity.addComponent stashed
  stashed

unstashComponent = (entity, name) ->
  entity.each T.Stashed, (stashed) ->
    if stashed.name == name
      comp = stashed.stashed
      entity.addComponent comp
      entity.deleteComponent stashed
  null

module.exports = -> new EnemyHitSystem()

