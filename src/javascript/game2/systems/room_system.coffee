StateMachineSystem = require '../../ecs2/state_machine_system'
EntitySearch = require '../../ecs2/entity_search'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'

# Enemies = require '../entity/enemies'
# Items = require '../entity/items'
# Doors = require '../entity/doors'
MapConfig = require '../../game/map/config'

# EntityStore = require '../../ecs/entity_store'
# enemyFilter = EntityStore.expandSearch(['enemy','position'])
# pickupFilter = EntityStore.expandSearch(['pickup','position'])

enemySearcher = EntitySearch.prepare([T.Enemy,T.Position])
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
    @publishEvent @eid, 'ready'

  setupRoomAction: ->
    roomComp = @entity.get(T.Room)
    roomId = roomComp.roomId
    roomPos = @entity.get(T.Position)

    worldMap = @input.getIn(['static','worldMap'])
    mapRoom = worldMap.getRoomById(roomId)
    roomDef = mapRoom.roomDef


    # Spawn enemies:
    for [col,row,type] in (roomDef.enemies || [])
      x = roomPos.x + (col * MapConfig.tileWidth)
      y = roomPos.y + (row * MapConfig.tileHeight)
      @estore.createEntity Prefab.enemy type,
        position:
          x: x
          y: y

    # Spawn items:
    hoff = 8
    voff = 8
    if roomDef.items?
      for itemDef in roomDef.items
         # TODO searcher for collected items
        collectedItems = {itemIds: ["item-1"]} # XXX
        {col,row,type,id} = itemDef
        if @itemStillInWorld(id,collectedItems)
          x = roomPos.x + (col * MapConfig.tileWidth) + hoff
          y = roomPos.y + (row * MapConfig.tileHeight) + voff
          @estore.createEntity Prefab.drop(
            pickup:
              itemType: type
              itemId: id
            position:
              x: x
              y: y
          )


    # Spawn doors:
    if roomDef.fixtures? and roomDef.fixtures['doors']?
      for [style,col,row] in roomDef.fixtures['doors']
        x = roomPos.x + (col * MapConfig.tileWidth)
        y = roomPos.y + (row * MapConfig.tileHeight)
        compLists = Prefab.doorEntities x:x, y:y, style:style, roomId:roomId
        for comps in compLists
          @estore.createEntity comps
      
  teardownRoomAction: ->
    roomComp = @entity.get(T.Room)
    roomId = roomComp.roomId
    roomPos = @entity.get(T.Position)
    worldMap = @input.getIn(['static','worldMap'])

    roomLeft = roomPos.x
    roomTop = roomPos.y
    roomRight = roomLeft + MapConfig.roomWidthInPixels
    roomBottom = roomTop + MapConfig.roomHeightInPixels

    # Despawn enemies
    enemySearcher.run @estore, (r) ->
      [enemy,pos] = r.comps
      if pos.x >= roomLeft and pos.x < roomRight and pos.y >= roomTop and pos.y < roomBottom
        r.entity.destroy()
    
    # TODO Despawn powerups
    # @searchEntities(pickupFilter).forEach (comps) =>
    #   pos = comps.get('position')
    #   if pos.x >= roomLeft and pos.x < roomRight and pos.y >= roomTop and pos.y < roomBottom
    #     @destroyEntity pos.get('eid')
    
    # Remove doors
    gelSearcher = EntitySearch.prepare([{type:T.DoorGel,roomId:roomId}]) # TODO figure out how to parameterize searchers
    gelSearcher.run @estore, (r) ->
      r.entity.destroy()
    frameSearcher = EntitySearch.prepare([{type:T.DoorFrame,roomId:roomId}])
    frameSearcher.run @estore, (r) ->
      r.entity.destroy()

    # Remove room
    @entity.destroy()

  itemStillInWorld: (itemId,collectedItems) ->
    # console.log "RoomSystem item still in world?",itemId
    for id in collectedItems.itemIds
      if itemId == id
        return true
    return false


module.exports = -> new RoomSystem()

