TileSearch = require('./tile_search')
MathUtils = require('../../utils/math_utils')
FnUtils = require('../../utils/fn_utils')

Config = require './config'
Utils = require './utils'
emptyGrid = Utils.emptyGrid

RoomDefs = require './room_defs'
Types = require './types'

instanceRoom = (roomDef,area,r,c) ->
  if roomDef?
    room = new Types.Room
      id: "room_r#{r}_c#{c}"
      roomDef: roomDef
      area: area
      row:r
      col:c
      x: c * Config.roomWidthInPixels
      y: r * Config.roomHeightInPixels
    room.tiles = tilesForRoom(room)
    room
  else
    null

updateBounds = (area,r,c) ->
  if !area.rowColBounds.leftCol?
    area.rowColBounds.leftCol = c
  else if c < area.rowColBounds.leftCol
    area.rowColBounds.leftCol = c

  if !area.rowColBounds.rightCol?
    area.rowColBounds.rightCol = c
  else if c > area.rowColBounds.rightCol
    area.rowColBounds.rightCol = c

  if !area.rowColBounds.topRow?
    area.rowColBounds.topRow = r
  else if r < area.rowColBounds.topRow
    area.rowColBounds.topRow = r

  if !area.rowColBounds.bottomRow?
    area.rowColBounds.bottomRow = r
  else if r > area.rowColBounds.bottomRow
    area.rowColBounds.bottomRow = r
  
  area.bounds.left   =  area.rowColBounds.leftCol      * Config.roomWidthInPixels
  area.bounds.top    =  area.rowColBounds.topRow       * Config.roomHeightInPixels
  area.bounds.right  = (area.rowColBounds.rightCol+1)  * Config.roomWidthInPixels
  area.bounds.bottom = (area.rowColBounds.bottomRow+1) * Config.roomHeightInPixels
      
getArea = (areas,name,r,c) ->
  area = areas[name]
  if !area?
    area = new Types.Area
      name: name
      music: "brinstar"
      rowColBounds: {}
      bounds: {}
    areas[name] = area
  updateBounds(area,r,c)

  return area

# Convert a grid of room types into a grid of room data objects
mapDefToRoomGrid = (mapDef, roomDefs, mapConfig) ->
  areas = {}
  roomGrid = emptyGrid(mapDef.rows, mapDef.cols)
  for row,r in mapDef.data
    for pair,c in row
      if pair?
        [roomTypeId,areaName] = pair.split("-")
        roomTypeId = parseInt(roomTypeId,16)
        roomDef = roomDefs.get(roomTypeId)
        area = getArea(areas, areaName, r, c)
        roomGrid[r][c] = instanceRoom(roomDef,area,r,c)

  roomGrid

# Convert a roomDef's grid of tile types into a grid of tile data objects
tilesForRoom = (room) ->
  outRows = []
  for row,r in room.roomDef.grid
    outRow = []
    outRows.push outRow
    for tileType,c in row
      if tileType?
        x = c * Config.tileWidth
        y = r * Config.tileHeight
        tile = new Types.Tile
          type: tileType
          room: room
          x: x
          y: y
          width: Config.tileWidth
          height: Config.tileHeight
          worldX: room.x + x
          worldY: room.y + y
          row: r
          col: c
          worldRow: r + room.row * Config.roomHeight
          worldCol: c + room.col * Config.roomWidth
        outRow.push tile
      else
        outRow.push null
  outRows

# Convert the populated grid of rooms, create a world-wide tile grid.
# (Used by MapPhysics to search for tile collisions)
roomGridToTileGrid = (roomGrid) ->
  roomRowCount = roomGrid.length
  roomColCount = roomGrid[0].length
  tileGrid = emptyGrid(roomRowCount*Config.roomHeight, roomColCount*Config.roomWidth)
  for roomRow,rri in roomGrid
    for room,ri in roomRow
      if room?
        for roomTileRow in room.tiles
          for tile in roomTileRow
            if tile?
              tileGrid[tile.worldRow][tile.worldCol] = tile
  tileGrid

# Retuen a list of all rooms, and a mapping from room.id -> room
indexRoomGrid = (roomGrid) ->
  index = {}
  all = []
  for row in roomGrid
    for room in row
      if room?
        index[room.id] = room
        all.push room
  return [all,index]

class WorldMap
  constructor: ({@roomGrid,@tileGrid}) ->
    [@rooms, @_roomsById] = indexRoomGrid(@roomGrid)

  # Return an array of Rooms that overlap the given px rectangle
  searchRooms: (top,left,bottom,right) ->
    TileSearch.search2d(@roomGrid,Config.roomWidthInPixels,Config.roomHeightInPixels,top,left,bottom,right)

  # return the room containing x,y in px
  getRoomAt: (x,y) ->
    TileSearch.searchXY(@roomGrid,Config.roomWidthInPixels,Config.roomHeightInPixels, x,y)

  # return the room with the given id
  getRoomById: (roomId) ->
    @_roomsById[roomId]

  # Return an array of tiles that overlap the given horizontal line
  tileSearchHorizontal: (y,left,right) ->
    TileSearch.searchHorizontal(@tileGrid, Config.tileWidth, Config.tileHeight, y, left, right)

  # Return an array of tiles that overlap the given verical line
  tileSearchVertical: (x,top,bottom) ->
    TileSearch.searchVertical(@tileGrid, Config.tileWidth, Config.tileHeight, x, top, bottom)

  # Return the Area containing the given px location
  getAreaAt: (x,y) ->
    if room = @getRoomAt(x,y)
      room.area
    else
      null

expandWorldMap = (mapDef) ->
  if !mapDef?
    console.log "!! WorldMap.expandWorldMap called with bad mapDef",mapDef
    return

  console.log mapDef
  roomGrid = mapDefToRoomGrid(mapDef, RoomDefs)
  tileGrid = roomGridToTileGrid(roomGrid)
  new WorldMap
    roomGrid: roomGrid
    tileGrid: tileGrid

# proto_mapDef =
#   rows: 5
#   cols: 15
#   data: [
#     [null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]
#     ['0x08-A', '0x17-A', '0x09-A', '0x14-A', '0x13-A',  '0x18-B',  '0x12-C', '0x14-C', '0x19-C', '0x13-C',  '0x12-D', '0x14-D', '0x14-D', '0x14-D', '0x13-D']
#   ]

module.exports =
  # getDefaultWorldMap: FnUtils.memoizeThunk -> expandWorldMap(proto_mapDef)
  buildMap: expandWorldMap


