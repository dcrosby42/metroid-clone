BaseSystem = require '../../../../ecs/base_system'
StateMachineSystem = require '../../../../ecs/state_machine_system'
Samus = require '..'
# Common = require '../../components'
# Immutable = require 'immutable'
# StateMachineSystem = require '../../../../ecs/state_machine_system'

# class SamusMaruMariSystem extends BaseSystem
class SamusMorphSystem extends StateMachineSystem
  @Subscribe: ['maru_mari', 'samus', 'hit_box']

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
    console.log 'morphIntoBallAction'
    # Add morphball component
    @addComp Samus.components.MorphBall
    # Remove suit component
    suit = @getEntityComponent @eid(), 'suit'
    @deleteComp suit
    # TODO: Change hitbox
    @setProp 'hit_box', 'height', 14

  morphIntoSuitAction: ->
    console.log 'morphIntoSuitAction'
    # Add suit component
    @addComp Samus.components.Suit
    # Remove morphball component
    mb = @getEntityComponent @eid(), 'morph_ball'
    @deleteComp mb
    # TODO: Change hitbox
    @setProp 'hit_box', 'height', 29 # TODO this is duplcate knowledge from Samus factory


module.exports = SamusMorphSystem
