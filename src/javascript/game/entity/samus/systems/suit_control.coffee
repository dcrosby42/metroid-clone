BaseSystem = require '../../../../ecs/state_machine_system'
Immutable = require 'immutable'
imm = Immutable.fromJS
SuitMotionOracle = require './suit_motion_oracle'
  
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
    action1: 'gunTrigger'
    action1Released: 'gunTriggerReleased'
    selectPressed: 'cycleWeapon'
  standing:
    action2Pressed: 'jump'
    down: 'crouch'
  running:
    action2Pressed: 'jump'
    # action2Pressed: 'spinJump' # TODO
  airborn:
    up: 'aimUp'
    upReleased: 'aimStraight'
    action1: 'gunTrigger'
    action1Released: 'gunTriggerReleased'
    selectPressed: 'cycleWeapon'
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

class SuitControlSystem extends BaseSystem
  @Subscribe: [ 'suit', 'samus', 'motion' ]

  process: ->
    motion = @getComp('motion')
    oracle = new SuitMotionOracle(motion)
    handleEventsByState @getEvents(), oracle, MotionStates, (name,data=null) =>
      switch name
        # as a shortcut we handle some suit posture events right here:
        when 'faceLeft'
          @setProp 'samus','direction','left'
        when 'faceRight'
          @setProp 'samus','direction','right'
        when 'aimUp'
          @setProp 'samus','aim','up'
        when 'aimStraight'
          @setProp 'samus','aim','straight'
        else
          # most events go through here:
          if name == 'selectPressed'
            console.log "SuitControl: selectPressed"
          @publishEvent name,data

handleEventsByState = (events,oracle,stateMap,callback) ->
  events.forEach (e) ->
    stateMap.forEach (actions,state) =>
      if oracle[state]?()
        mappedEvent = actions.get(e.get('name'))
        if mappedEvent?
          callback(mappedEvent,null)

module.exports = SuitControlSystem
