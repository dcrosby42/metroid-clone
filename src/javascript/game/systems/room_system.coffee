StateMachineSystem = require '../../ecs/state_machine_system'
Common = require '../entity/components'
Enemies = require '../entity/enemies'
Doors = require '../entity/doors'

FilterExpander = require '../../ecs/filter_expander'
enemyFilter = FilterExpander.expandFilterGroups(['enemy','position'])

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
    roomPos = @getComp 'position'
    worldMap = @input.getIn(['static','worldMap'])
    roomDef = worldMap.getRoomById(roomId)

    # Spawn enemies:
    for [col,row,id] in (roomDef.enemies || [])
      x = roomPos.get('x') + (col * worldMap.tileWidth)
      y = roomPos.get('y') + (row * worldMap.tileHeight)
      @newEntity Enemies.factory.createComponents(id, x:x, y:y)

    # Spawn doors:
    for [style,col,row] in (roomDef.doors || [])
      x = roomPos.get('x') + (col * worldMap.tileWidth)
      y = roomPos.get('y') + (row * worldMap.tileHeight)
      @newEntity Doors.factory.createComponents('doorEnclosure', x:x,y:y, style:style)
      @newEntity Doors.factory.createComponents('doorGel', x:x, y:y, style:style)


      
  teardownRoomAction: ->
    roomId = @getProp 'room', 'roomId'
    roomPos = @getComp 'position'
    worldMap = @input.getIn(['static','worldMap'])

    roomLeft = roomPos.get('x')
    roomTop = roomPos.get('y')
    roomRight = roomLeft + worldMap.roomWidthInPx
    roomBottom = roomTop + worldMap.roomHeightInPx

    # Despawn enemies
    @estore.search(enemyFilter).forEach (comps) =>
      epos = comps.get('position')
      if epos.get('x') >= roomLeft and epos.get('x') < roomRight and epos.get('y') >= roomTop and epos.get('y') < roomBottom
        @destroyEntity epos.get('eid')
    
    # Remove doors
    # TODO

    # Remove room
    @destroyEntity()



module.exports = RoomSystem

