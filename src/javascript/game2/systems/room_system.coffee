StateMachineSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

# Common = require '../entity/components'
# Enemies = require '../entity/enemies'
# Items = require '../entity/items'
# Doors = require '../entity/doors'
MapConfig = require '../../game/map/config'

# EntityStore = require '../../ecs/entity_store'
# enemyFilter = EntityStore.expandSearch(['enemy','position'])
# pickupFilter = EntityStore.expandSearch(['pickup','position'])

# enemySearcher = EntitySearch.prepare([T.Enemy,T.Position])
# pickupSearcher = EntitySearch.prepare([T.Pickup,T.Position])

class RoomSystem extends StateMachineSystem
  @Subscribe: [
    [T.Room,T.Position]
    # [T.CollectedItems]
  ]
  @StateMachine:
    componentProperty: [0,'state']
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
    roomComp = @entity.get(T.Room)
    roomId = roomComp.roomId
    roomPos = @entity.get(T.Position)

    worldMap = @input.getIn(['static','worldMap'])
    mapRoom = worldMap.getRoomById(roomId)
    roomDef = mapRoom.roomDef


    # Spawn enemies:
    for [col,row,id] in (roomDef.enemies || [])
      x = roomPos.x + (col * MapConfig.tileWidth)
      y = roomPos.y + (row * MapConfig.tileHeight)
      # TODO: create new enemy component
      # comps = Enemies.factory.createComponents(id, x:x, y:y)
      # @newEntity comps

    # Spawn items:
    hoff = 8
    voff = 8
    if roomDef.items?
      for itemDef in roomDef.items
         # TODO searcher for collected items
        {col,row,type,id} = itemDef
        if @itemStillInWorld(id,collectedItems) 
          x = roomPos.x + (col * MapConfig.tileWidth) + hoff
          y = roomPos.y + (row * MapConfig.tileHeight) + voff
          #TODO create new item entity
          # comps = Items.factory.createPickup
          #   pickup: { itemType: type, itemId: id }
          #   position: {x: x, y: y}
          # @newEntity comps


    # Spawn doors:
    if roomDef.fixtures? and roomDef.fixtures['doors']?
      for [style,col,row] in roomDef.fixtures['doors']
        x = roomPos.x + (col * MapConfig.tileWidth)
        y = roomPos.y + (row * MapConfig.tileHeight)
        #TODO create new door entities
        # doorEnclosure = Doors.factory.createComponents('doorEnclosure', x:x,y:y, style:style, roomId: roomId)
        # doorGel = Doors.factory.createComponents('doorGel', x:x, y:y, style:style, roomId: roomId)
        # @newEntity doorEnclosure
        # @newEntity doorGel

      
  teardownRoomAction: ->
    roomComp = @entity.get(T.Room)
    roomId = roomComp.roomId
    roomPos = @entity.get(T.Position)
    worldMap = @input.getIn(['static','worldMap'])

    roomLeft = roomPos.x
    roomTop = roomPos.y
    roomRight = roomLeft + MapConfig.roomWidthInPixels
    roomBottom = roomTop + MapConfig.roomHeightInPixels

    # TODO Despawn enemies
    # @searchEntities(enemyFilter).forEach (comps) =>
    #   pos = comps.get('position')
    #   if pos.x >= roomLeft and pos.x < roomRight and pos.y >= roomTop and pos.y < roomBottom
    #     @destroyEntity pos.get('eid')
    
    # TODO Despawn powerups
    # @searchEntities(pickupFilter).forEach (comps) =>
    #   pos = comps.get('position')
    #   if pos.x >= roomLeft and pos.x < roomRight and pos.y >= roomTop and pos.y < roomBottom
    #     @destroyEntity pos.get('eid')
    
    # TODO Remove doors
    # @searchEntities([{match:{type:'door_gel',roomId:roomId}, as: 'door_gel'}]).forEach (comps) =>
    #   @destroyEntity comps.getIn(['door_gel','eid'])
    # @searchEntities([{match:{type:'door_frame',roomId:roomId}, as: 'door_frame'}]).forEach (comps) =>
    #   @destroyEntity comps.getIn(['door_frame','eid'])

    # TODO Remove room
    # @destroyEntity()

  itemStillInWorld: (itemId,collectedItems) ->
   #TODO
    # collected = @getProp('collected_items','itemIds')
    # return !collected.has(itemId)


module.exports = RoomSystem

