StateMachineSystem = require '../../ecs/state_machine_system'
Common = require '../entity/components'
Enemies = require '../entity/enemies'

class RoomSystem extends StateMachineSystem
  @Subscribe: [ 'room', 'position' ]
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
    roomId = @getProp 'room', 'roomId'
    pos = @getComp 'position'
    worldMap = @input.getIn(['static','worldMap'])
    roomDef = worldMap.getRoomById(roomId)
    for [col,row,id] in (roomDef.enemies || [])
      x = pos.get('x') + (col * worldMap.tileWidth)
      y = pos.get('y') + (row * worldMap.tileHeight)
      ecomps = Enemies.factory.createComponents(id, x:x, y:y)
      @newEntity ecomps
      

    
        

  teardownRoomAction: ->
    # TODO: de-spawn creatures 
    @destroyEntity()


module.exports = RoomSystem

