BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types
  
MotionStates =
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
  # @Subscribe: [ 'suit', 'samus', 'motion' ]
  @Subscribe: [ T.Suit, T.Motion ]

  process: (r) ->
    [suit,motion] = r.comps
    oracle = motion.motions.oracle()
    window.oracle = oracle #WINDOWDEBUG
    handleEventsByState @getEvents(r.eid), oracle, MotionStates, (name,data=null) =>
      # console.log "SuitControlSystem handling event name",name
      switch name
        # as a shortcut we handle some suit posture events right here:
        when 'faceLeft'
          suit.direction = 'left'
        when 'faceRight'
          suit.direction = 'right'
        when 'aimUp'
          suit.aim = 'up'
        when 'aimStraight'
          suit.aim = 'straight'
        else
          # most events go through here:
          console.log "SuitControlSystem publish",r.eid,name,data
          @publishEvent r.eid, name,data

# TODO: move this somewhere else? it's duplicated in morph_ball_control_system
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

module.exports = -> new SuitControlSystem()
