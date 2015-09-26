StateMachineSystem = require '../../ecs/state_machine_system'
Common = require '../entity/components'

class RoomSystem extends StateMachineSystem
  @Subscribe: [ 'room' ]
  @StateMachine:
    componentProperty: ['room','state']
    start: 'begin'
    states:
      begin:
        events:
          ready:
            action: 'setupRoom'
            nextState: 'active'
      active:
        events:
          gone:
            action: 'teardownRoom'
            nextState: 'done'

  beginState: ->
    @publishEvent 'ready'

  setupRoomAction: ->
    console.log "RoomSystem.setupRoomAction", @getComp('room')
    # TODO: spawn creatures

  teardownRoomAction: ->
    console.log "RoomSystem.teardownRoomAction", @getComp('room')
    # TODO: de-spawn creatures 
    @destroyEntity()


module.exports = RoomSystem

