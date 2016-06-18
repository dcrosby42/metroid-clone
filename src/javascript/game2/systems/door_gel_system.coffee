Common = require '../../components'
StateMachineSystem = require '../../ecs2/state_machine_system'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'
# DoorComponents = require '../components'

class DoorGelSystem extends StateMachineSystem
  @Subscribe: [ T.DoorGel, T.Animation ]

  @StateMachine:
    componentProperty: [0, 'state']
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
    [ doorGel,animation] = @comps
    animation.state = 'opening'
    animation.time = 0

    @_makeDoorSound()

    @entity.addComponent Prefab.timerComponent
      time: 3000
      eventName: 'autoClose'

    # Remove the map fixture component of this gel that blocks passage
    @entity.each T.Tag, (tag) =>
      if tag.name == 'map_fixture'
        @entity.deleteComponent tag

  closeAction: ->
    [ doorGel,animation] = @comps
    animation.state = 'closing'
    animation.time = 0

    @_makeDoorSound()
    # Reintroduce the component that blocks passage:
    @entity.addComponent Prefab.tag('map_fixture')
    # @addComp Common.MapFixture

  _makeDoorSound: ->
    @estore.createEntity Prefab.sound
      soundId: 'door'
      volume: 0.5
      timeLimit: 1000

module.exports = -> new DoorGelSystem()
