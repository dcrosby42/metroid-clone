BaseSystem = require '../../../../ecs/base_system'
StateMachineSystem = require '../../../../ecs/state_machine_system'
Samus = require '..'
Common = require '../../components'
# Immutable = require 'immutable'
# StateMachineSystem = require '../../../../ecs/state_machine_system'

# class SamusMaruMariSystem extends BaseSystem
class SamusMorphSystem extends StateMachineSystem
  @Subscribe: ['maru_mari', 'samus', 'hit_box', 'position']

  @StateMachine:
    componentProperty: ['maru_mari', 'state']
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
    # Add morphball component
    @addComp Samus.components.MorphBall

    # Remove suit component
    suit = @getEntityComponent @eid(), 'suit'
    @deleteComp suit

    # Shrink hitbox
    @setProp 'hit_box', 'height', 15

    # start a little airborn
    @updateProp 'position', 'y', (y) -> y - 8

    # Make morph bloop sound
    @_clearSounds()
    @addComp Common.Sound.merge
      soundId: 'samus_morphball'
      # volume: 0.2
      volume: 1
      # playPosition: 0
      timeLimit: 100
      resound: true


  morphIntoSuitAction: ->
    # Add suit component
    @addComp Samus.components.Suit

    # Remove morphball component
    mb = @getEntityComponent @eid(), 'morph_ball'
    @deleteComp mb

    # Grow hitbox
    @setProp 'hit_box', 'height', 29 # TODO this is duplcate knowledge from Samus factory
    
    # start a little airborn
    @updateProp 'position', 'y', (y) -> y - 8
    
    # Make step sound
    @_clearSounds()
    @addComp Common.Sound.merge
      soundId: 'step'
      # volume: 0.5
      volume: 1
      # playPosition: 0
      timeLimit: 50
      resound: true

  _clearSounds: ->
    @getEntityComponents(@eid(), 'sound').forEach (s) =>
      @deleteComp s

module.exports = SamusMorphSystem
