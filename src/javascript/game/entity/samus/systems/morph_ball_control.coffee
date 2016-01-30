BaseSystem = require '../../../../ecs/state_machine_system'
Immutable = require 'immutable'
imm = Immutable.fromJS
MorphBallMotionOracle = require './morph_ball_motion_oracle'
  
MotionStates = imm
  any:
    left: 'rollLeft'
    right: 'rollRight'
    leftReleased: 'stop'
    rightReleased: 'stop'
  grounded:
    action1: 'bombTrigger'
    action1Released: 'bombTriggerReleased'
  inTheClear:
    up: 'stand'
  # parked:
  # rolling:
  # rising:
  # falling:
  # movingSideways:
  # airborn:

class MorphBallControlSystem extends BaseSystem
  @Subscribe: [ 'morph_ball', 'samus', 'motion' ]

  process: ->
    motion = @getComp('motion')
    oracle = new MorphBallMotionOracle(motion)
    @handleEventsByState oracle, MotionStates, (name,data=null) =>
      switch name
        when 'rollLeft'
          @setProp 'samus','direction','left'
        when 'rollRight'
          @setProp 'samus','direction','right'
      @publishEvent name,data

  # TODO: move this somewhere else? it's duplicated in suit_control_system
  handleEventsByState: (oracle,handlers,callback) ->
    handlers.forEach (handlers,state) =>
      if oracle[state]?()
        @getEvents().forEach (inEvent) ->
          ename = handlers.get(inEvent.get('name'))
          if ename?
            callback(ename,null)

module.exports = MorphBallControlSystem
