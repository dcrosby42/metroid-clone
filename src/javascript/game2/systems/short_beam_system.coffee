StateMachineSystem = require '../../ecs2/state_machine_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'

MuzzleVelocity = 200/1000
BulletLifetime = 50 / (200/1000)

class ShortBeamSystem extends StateMachineSystem
  @Subscribe: [T.ShortBeam, T.Suit, T.Position]

  @StateMachine:
    componentProperty: [0,'state']
    start: 'ready'
    states:
      ready:
        events:
          fireBeam:
            action:    'shoot'
            nextState: 'coolDown'
      coolDown:
        events:
          fireBeamReleased:
            action:    'reset'
            nextState: 'ready'
          cooldownComplete:
            nextState: 'repeating'
      repeating:
        events:
          keepFiring:
            action: 'repeat'
            nextState: 'coolDown'
          fireBeamReleased:
            action: 'reset'
            nextState: 'ready'

  shootAction: ->
    @_fireBullet()
    @_startCooldown(500)

  repeatingState: ->
    @publishEvent @eid, 'keepFiring'

  repeatAction: ->
    @_fireBullet()
    @_startCooldown(150)

  resetAction: ->
    # Clear cooldown timer(s):
    @entity.each T.timer, (timer) ->
      if timer.eventName == 'shortBeamCooldown'
        @entity.deleteComponent timer

  repeatState: ->
    @publishEvent @eid, 'done'
  

  _fireBullet: ->
    suit = @entity.get(T.Suit)
    shortBeam = @entity.get(T.ShortBeam)
    position = @entity.get(T.Position)
    @estore.createEntity(newBullet(suit,shortBeam, position))
    

  _startCooldown: (ms) ->
    timer = Prefab.timerComponent
      time: ms
      eventName: 'cooldownComplete'
      name: 'shortBeamCooldown'
    @entity.addComponent timer


newBullet = (suit, weapon, position) ->
  shootUp = suit.aim == 'up'
  direction = suit.direction
  offsetX = offsetY = vx = vy = 0

  if shootUp
    offsetX = 2.5
    offsetY = -35
    vx = 0
    vy = -MuzzleVelocity
    if direction == 'left'
      offsetX = -2
  else
    offsetX = 10
    offsetY = -22
    vx = MuzzleVelocity
    vy = 0
    if direction == 'left'
      offsetX = -offsetX
      vx = -vx

  fireX = position.x + offsetX
  fireY = position.y + offsetY

  return Prefab.bullet(
    bullet:
      damage: weapon.damage
    position:
      x: fireX
      y: fireY
    velocity:
      x: vx
      y: vy
    lifetime: BulletLifetime
  )
    
    


module.exports = -> new ShortBeamSystem()

