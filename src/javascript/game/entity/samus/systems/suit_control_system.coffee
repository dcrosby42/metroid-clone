BaseSystem = require '../../../../ecs/state_machine_system'
Immutable = require 'immutable'
imm = Immutable.fromJS
MotionOracle = require './motion_oracle'
  
MotionStates = imm
  any:
    left: 'faceLeft'
    right: 'faceRight'
  grounded:
    left: 'run'
    right: 'run'
    leftReleased: 'stop'
    rightReleased: 'stop'
    up: 'aimUp'
    upReleased: 'aimStraight'
    down: 'crouch'
    action1: 'gunTrigger'
    action1Released: 'gunTriggerReleased'
  standing:
    action2Pressed: 'jump'
  running:
    action2Pressed: 'jump'
    # action2Pressed: 'spinJump' # TODO
  airborn:
    up: 'aimUp'
    upReleased: 'aimStraight'
    action1: 'gunTrigger'
    action1Released: 'gunTriggerReleased'
  rising:
    action2Released: 'fall'
  floating:
    left: 'drift'
    right: 'drift'
    leftReleased: 'stop'
    rightReleased: 'stop'
  spinning:
    left: 'tumble'
    right: 'tumble'

transformEvents = (events,oracle, fn) ->
  MotionStates.forEach (handlers,state) ->
    if oracle[state]?()
      events.forEach (inEvent) ->
        ename = handlers.get(inEvent.get('name'))
        if ename?
          fn(ename)


class SuitControlSystem extends BaseSystem
  @Subscribe: [ 'suit', 'samus', 'motion' ]

  process: ->
    motion = @getComp('motion')
    events = @getEvents()
    oracle = new MotionOracle(motion)
    transformEvents events, oracle, (e,data=null) =>
      switch e
        when 'faceLeft'
          @setProp 'samus','direction','left'
        when 'faceRight'
          @setProp 'samus','direction','right'
        when 'aimUp'
          @setProp 'samus','aim','up'
        when 'aimStraight'
          @setProp 'samus','aim','straight'
        else
          @publishEvent e,data

module.exports = SuitControlSystem
