StateMachineSystem = require '../../ecs/state_machine_system'
Common = require '../entity/components'
Enemies = require '../entity/enemies'
Items = require '../entity/items'
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


    # Spawn items:
    hoff = 8
    voff = 8
    for [col,row,id] in (roomDef.items || [])
      x = roomPos.get('x') + (col * worldMap.tileWidth) + hoff
      y = roomPos.get('y') + (row * worldMap.tileHeight) + voff
      @newEntity Items.factory.createComponents(id, position: {x: x, y: y})


    # Spawn doors:
    for [style,col,row] in (roomDef.doors || [])
      x = roomPos.get('x') + (col * worldMap.tileWidth)
      y = roomPos.get('y') + (row * worldMap.tileHeight)
      @newEntity Doors.factory.createComponents('doorEnclosure', x:x,y:y, style:style, roomId: roomId)
      @newEntity Doors.factory.createComponents('doorGel', x:x, y:y, style:style, roomId: roomId)

    # TODO: spawn powerups

      
  teardownRoomAction: ->
    roomId = @getProp 'room', 'roomId'
    roomPos = @getComp 'position'
    worldMap = @input.getIn(['static','worldMap'])

    roomLeft = roomPos.get('x')
    roomTop = roomPos.get('y')
    roomRight = roomLeft + worldMap.roomWidthInPx
    roomBottom = roomTop + worldMap.roomHeightInPx

    # Despawn enemies
    @searchEntities(enemyFilter).forEach (comps) =>
      epos = comps.get('position')
      if epos.get('x') >= roomLeft and epos.get('x') < roomRight and epos.get('y') >= roomTop and epos.get('y') < roomBottom
        @destroyEntity epos.get('eid')
    
    # Remove doors
    @searchEntities([{match:{type:'door_gel',roomId:roomId}, as: 'door_gel'}]).forEach (comps) =>
      @destroyEntity comps.getIn(['door_gel','eid'])

    @searchEntities([{match:{type:'door_frame',roomId:roomId}, as: 'door_frame'}]).forEach (comps) =>
      @destroyEntity comps.getIn(['door_frame','eid'])

    # Remove room
    @destroyEntity()



module.exports = RoomSystem

