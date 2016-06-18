StateMachineSystem = require '../../ecs2/state_machine_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'

# Common = require '../../components'
# Immutable = require 'immutable'
# StateMachineSystem = require '../../../../ecs/state_machine_system'

MuzzleVelocity = 200/1000

class MissileLauncherSystem extends StateMachineSystem
  @Subscribe: [T.MissileLauncher, T.Suit, T.Position]

  @StateMachine:
    componentProperty: [0,'state']
    start: 'ready'
    states:
      ready:
        events:
          fireMissile:
            action:    'shoot'
            nextState: 'coolDown'
      coolDown:
        events:
          fireMissileReleased:
            action:    'reset'
            nextState: 'ready'
          missileCooldownComplete:
            nextState: 'repeating'
      repeating:
        events:
          keepFiring:
            action: 'repeat'
            nextState: 'coolDown'
          fireMissileReleased:
            action: 'reset'
            nextState: 'ready'

  # readyState: ->
  #   console.log "missilelaunchersystem readyState"
  shootAction: ->
    @_fireMissile()
    @_startCooldown(500)

  repeatingState: ->
    @publishEvent @eid, 'keepFiring'

  repeatAction: ->
    @_fireMissile()
    @_startCooldown(150)

  resetAction: ->
    # Clear cooldown timer(s):
    @entity.each T.Timer, (timer) ->
      if timer.eventName == 'missileCooldown'
        @entity.deleteComponent timer

  _fireMissile: ->
    [missileLauncher, suit, position] = @comps


    if missileLauncher.count <= 0
      return
    missileLauncher.count -= 1
    
    @estore.createEntity newMissile(missileLauncher,suit,position)

  _startCooldown: (ms) ->
    @entity.addComponent Prefab.timerComponent
      time: ms
      eventName: 'missileCooldownComplete'
      name: 'missileCooldown'


newMissile = (missileLauncher,suit,position) ->
  offsetX = offsetY = vx = vy = 0

  shootUp = suit.aim == 'up'

  missileDir = suit.direction
  if shootUp
    offsetX = 2.5
    offsetY = -37
    vx = 0
    vy = -MuzzleVelocity
    if suit.direction == 'left'
      offsetX = -3
    missileDir = "up"
  else
    offsetX = 13
    offsetY = -20
    vx = MuzzleVelocity
    vy = 0
    if suit.direction == 'left'
      offsetX = -offsetX
      vx = -vx

  fireX = position.x + offsetX
  fireY = position.y + offsetY

  return Prefab.missile(
    direction: missileDir
    position:
      x: fireX
      y: fireY
    velocity:
      x: vx
      y: vy

  )




module.exports = -> new MissileLauncherSystem()

