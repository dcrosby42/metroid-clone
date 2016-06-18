StateMachineSystem = require '../../ecs2/state_machine_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'
MathUtils = require '../../utils/math_utils'

class SamusDamageSystem extends StateMachineSystem
  @Subscribe: [ T.Damaged, {type:T.Tag, name:"samus"}, T.Health, T.Velocity ]

  @StateMachine:
    componentProperty: [0,'state']
    start: 'new'
    states:
      new:
        events:
          hit:
            action: 'damage'
            nextState: 'recoiling'
      recoiling:
        events:
          damageRecoilExpired:
            nextState: 'gracePeriod'

      gracePeriod:
        events:
          damageGracePeriodExpired:
            action: 'backToNormal'
            nextState: 'done'
      done: {}

  newState: ->
    @publishEvent @eid, 'hit'

  damageAction: ->
    [damaged,samus,health,velocity] = @comps
    health.hp -= damaged.damage
    if health.hp < 0
      # u got ded
      @entity.destroy()
      @estore.createEntity [ C.buildCompForType T.Death ]
    else
      @_makeHurtSound()

      @entity.addComponent Prefab.timerComponent
        time: 300
        eventName: 'damageRecoilExpired'

      @entity.addComponent Prefab.timerComponent
        time: 750
        eventName: 'damageGracePeriodExpired'

  recoilingState: ->
    [damaged,samus,health,velocity] = @comps
    velocity.x = MathUtils.clamp(velocity.x + damaged.impulseX, -0.088, 0.088)
    velocity.y = MathUtils.clamp(velocity.y + damaged.impulseY, -0.1, 0.2)

  backToNormalAction: ->
    [damaged,samus,health,velocity] = @comps
    @entity.addComponent C.buildCompForType T.Tag, name:'vulnerable'
    @entity.deleteComponent damaged

  _makeHurtSound: ->
    @estore.createEntity Prefab.sound
      soundId: 'samus_hurt'
      volume: 0.2
      playPosition: 0
      timeLimit: 170


module.exports = -> new SamusDamageSystem()
