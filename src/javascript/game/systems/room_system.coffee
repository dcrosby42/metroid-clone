StateMachineSystem = require '../../ecs/state_machine_system'
Common = require '../entity/components'
Enemies = require '../entity/enemies'
Items = require '../entity/items'
Doors = require '../entity/doors'
MapConfig = require '../map/config'

EntityStore = require '../../ecs/entity_store'
enemyFilter = EntityStore.expandSearch(['enemy','position'])

class RoomSystem extends StateMachineSystem
  @Subscribe: [
    ['room', 'position'],
    ['collected_items']
  ]
  @ImplyEntity: 'room'
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
    roomPos = @getComp 'room-position'
    worldMap = @input.getIn(['static','worldMap'])
    mapRoom = worldMap.getRoomById(roomId)
    roomDef = mapRoom.roomDef

    # Spawn enemies:
    for [col,row,id] in (roomDef.enemies || [])
      x = roomPos.get('x') + (col * MapConfig.tileWidth)
      y = roomPos.get('y') + (row * MapConfig.tileHeight)
      comps = Enemies.factory.createComponents(id, x:x, y:y)
      cjs = _.map comps, (c) -> c.toJS()
      @newEntity comps

    # Spawn items:
    hoff = 8
    voff = 8
    for itemDef  in (roomDef.items || [])
      {col,row,type,id} = itemDef
      if @itemStillInWorld(id)
        x = roomPos.get('x') + (col * MapConfig.tileWidth) + hoff
        y = roomPos.get('y') + (row * MapConfig.tileHeight) + voff
        @newEntity Items.factory.createComponents(type, powerup: { itemId: id }, position: {x: x, y: y})

    # Spawn doors:
    for [style,col,row] in ((roomDef.fixtures || {})['doors'] || [])
      x = roomPos.get('x') + (col * MapConfig.tileWidth)
      y = roomPos.get('y') + (row * MapConfig.tileHeight)
      doorEnclosure = Doors.factory.createComponents('doorEnclosure', x:x,y:y, style:style, roomId: roomId)
      doorGel = Doors.factory.createComponents('doorGel', x:x, y:y, style:style, roomId: roomId)
      @newEntity doorEnclosure
      @newEntity doorGel

      
  teardownRoomAction: ->
    roomId = @getProp 'room', 'roomId'
    roomPos = @getComp 'room-position'
    worldMap = @input.getIn(['static','worldMap'])

    roomLeft = roomPos.get('x')
    roomTop = roomPos.get('y')
    roomRight = roomLeft + MapConfig.roomWidthInPixels
    roomBottom = roomTop + MapConfig.roomHeightInPixels

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

  itemStillInWorld: (itemId) ->
    collected = @getProp('collected_items','itemIds')
    return !collected.has(itemId)


module.exports = RoomSystem

