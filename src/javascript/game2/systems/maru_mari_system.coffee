StateMachineSystem = require '../../ecs2/state_machine_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'

# Samus = require '..'
# Common = require '../../components'
# Immutable = require 'immutable'
# StateMachineSystem = require '../../../../ecs/state_machine_system'

class MaruMariSystem extends StateMachineSystem
  # @Subscribe: ['maru_mari', 'samus', 'hit_box', 'position']
  @Subscribe: [T.MaruMari, T.HitBox, T.Position]

  @StateMachine:
    componentProperty: [0, 'state']
    start: 'inactive'
    states:
      inactive:
        events:
          crouch:
            action: 'morphIntoBall'
            nextState: 'active'
      active:
        events:
          stand:
            action: 'morphIntoSuit'
            nextState: 'inactive'

  morphIntoBallAction: ->
    [_maruMari, hitBox, position]= @comps
    
    morphBall = Prefab.morphBallComponent()
    @entity.addComponent morphBall
    
    # Remove suit component
    if suit = @entity.get T.Suit
      morphBall.direction = suit.direction
      @entity.deleteComponent suit


    # Shrink hitbox
    hitBox.height = 15

    # start a little airborn
    position.y -= 8

    # Make morph bloop sound
    @_clearSounds()
    @entity.addComponent Prefab.soundComponent(
      soundId: 'samus_morphball'
      volume: 1
      timeLimit: 100
      resound: true
    )


  morphIntoSuitAction: ->
    [_maruMari, hitBox, position]= @comps
    # Add suit component
    @entity.addComponent Prefab.suitComponent()
    # @addComp Samus.components.Suit

    # Remove morphball component
    if ball = @entity.get T.MorphBall
      @entity.deleteComponent ball

    # Grow hitbox
    hitBox.height = 29# FIXME this is duplcate knowledge from Samus prefab
    
    # start a little airborn
    position.y -= 8
    
    # Make step sound
    @_clearSounds()

    @entity.addComponent Prefab.soundComponent
      soundId: 'step'
      volume: 1
      timeLimit: 50
      resound: true

  _clearSounds: ->
    @entity.each T.Sound, (s) =>
      @entity.deleteComponent s

module.exports = -> new MaruMariSystem()
