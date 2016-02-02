Common = require '../../components'
DoorComponents = require '../components'
StateMachineSystem = require '../../../../ecs/state_machine_system'

class DoorGelSystem extends StateMachineSystem
  @Subscribe: [ 'door_gel', 'animation' ]

  @StateMachine:
    componentProperty: ['door_gel', 'state']
    start: 'closed'
    states:
      closed:
        events:
          shot:
            action: 'open'
            nextState: 'opened'
      opened:
        events:
          autoClose:
            action: 'close'
            nextState: 'closed'

  openAction: ->
    @setProp 'animation', 'state', 'opening'
    @setProp 'animation', 'time', 0

    @_makeDoorSound()

    @addComp Common.Timer.merge
      time: 3000
      event: 'autoClose'

    # Remove the component of this gel that blocks passage
    @deleteComp @getEntityComponent(@eid(), 'map_fixture')

  closeAction: ->
    @setProp 'animation', 'state', 'closing'
    @setProp 'animation', 'time', 0
    @_makeDoorSound()
    # Reintroduce the component that blocks passage:
    @addComp Common.MapFixture

  _makeDoorSound: ->
    @newEntity [
      Common.Sound.merge
        soundId: 'door'
        volume: 0.5
        timeLimit: 1000
    ]

module.exports = DoorGelSystem
