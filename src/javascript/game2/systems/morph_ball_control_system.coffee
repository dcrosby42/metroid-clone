BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'

# MorphBallMotionOracle = require './morph_ball_motion_oracle'
  
MotionStates =
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
  @Subscribe: [ T.MorphBall, T.Motion ]

  process: (r) ->
    [morphBall, motion] = r.comps
    # oracle = new MorphBallMotionOracle(motion)
    oracle = motion.motions.morphBallOracle()
    handleEventsByState @getEvents(r.eid), oracle, MotionStates, (name,data=null) =>
      switch name
        when 'rollLeft'
          morphBall.direction = 'left'
          # @setProp 'samus','direction','left'
        when 'rollRight'
          morphBall.direction = 'right'
          # @setProp 'samus','direction','right'
      @publishEvent r.eid,name,data

# TODO: move this somewhere else? it's duplicated in suit_control_system
handleEventsByState = (events,oracle,stateMap,callback) ->
  events.forEach (e) ->
    # console.log "event:",e.toJS()
    eventName = e.get('name')
    for state,actions of stateMap
      # console.log "state,actions",state,actions
      # console.log "oracle",oracle
      if oracle[state]?()
        mappedEvent = actions[eventName]
        if mappedEvent?
          callback(mappedEvent,null)


# @handleEventsByState: (oracle,handlers,callback) ->
#   handlers.forEach (handlers,state) =>
#     if oracle[state]?()
#       @getEvents().forEach (inEvent) ->
#         ename = handlers.get(inEvent.get('name'))
#         if ename?
#           callback(ename,null)

module.exports = -> new MorphBallControlSystem()
