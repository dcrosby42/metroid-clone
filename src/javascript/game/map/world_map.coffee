TileSearch = require('./tile_search')
MathUtils = require('../../utils/math_utils')
FnUtils = require('../../utils/fn_utils')

Config = require './config'
Utils = require './utils'
emptyGrid = Utils.emptyGrid

RoomDefs = require './room_defs'
Types = require './types'

# Convert a grid of room types into a grid of room data objects
mapLayoutToRoomGrid = (mapLayout, roomDefs, mapConfig) ->
  roomGrid = emptyGrid(mapLayout.rows, mapLayout.cols)
  console.log "roomGrid before:",roomGrid
  for row,r in mapLayout.data
    for roomTypeId,c in row
      roomDef = roomDefs.get(roomTypeId)
      if roomDef?
        room = new Types.Room
          id: "room_r#{r}_c#{c}"
          roomDef: roomDef
          row:r
          col:c
          x: c * Config.roomWidthInPixels
          y: r * Config.roomHeightInPixels
        room.tiles = tilesForRoom(room)
        roomGrid[r][c] = room
      else
        # TODO: determine if this is an error or is normal
        console.log "!! ERR: No roomDef for roomTypeId=#{roomTypeId} at row=#{r} col=#{c}"

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

# Relate rooms to their areas (and vice versa) comparing the Area's defined coverage to the rooms' locations.
# Sets room.area and adds to area.rooms[]
setRoomAreas = (roomGrid,areas) ->
  for row in roomGrid
    for room in row
      if room?
        for area in areas
          a = area.rowColBounds
          if room.row >= a.topRow && room.row <= a.bottomRow && room.col >= a.leftCol && room.col <= a.rightCol
            room.area = area
            area.rooms.push(room)


# Retuen a mapping from room.id -> room
indexRoomGrid = (roomGrid) ->
  index = {}
  for row in roomGrid
    for room in row
      if room?
        index[room.id] = room
  index

# Convert an area's metadata def into a Types.Area object
makeArea = (areaDef) ->
  [name, [topRow,leftCol],[bottomRow,rightCol]] = areaDef
  new Types.Area
    name: name
    rowColBounds:
      topRow: topRow
      bottomRow: bottomRow
      leftCol: leftCol
      rightCol: rightCol
    bounds:
      left: leftCol * Config.roomWidthInPixels
      top: topRow * Config.roomHeightInPixels
      right: (rightCol+1) * Config.roomWidthInPixels
      bottom: (bottomRow+1) * Config.roomHeightInPixels
    rooms: []
    zone: null
    music: "brinstar"

class WorldMap
  constructor: ({@roomGrid,@tileGrid,@areas}) ->
    @_roomsById = indexRoomGrid(@roomGrid)

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

  @create: (layout) ->

expandWorldMap = (layout) ->
  roomGrid = mapLayoutToRoomGrid(layout, RoomDefs)
  tileGrid = roomGridToTileGrid(roomGrid)
  areas = _.map layout.areas, (areaDef) -> makeArea(areaDef)
  setRoomAreas(roomGrid,areas)
  new WorldMap
    roomGrid: roomGrid
    tileGrid: tileGrid
    areas: areas

mapDef =
  rows: 10
  cols: 10
  data: [
    # mainEntry-------------------  roomA-----------------   roomB----------------------- 
    [0x08, 0x17, 0x09, 0x14, 0x13,  0x12, 0x14, 0x19, 0x13,  0x12, 0x14, 0x14, 0x14, 0x13]
  ]
  areas: [
    ["mainEntry", [0,0], [0,4]]
    ["roomA", [0,5], [0,8]]
    ["roomB", [0,9], [0,13]]
  ]

module.exports =
  getDefaultWorldMap: FnUtils.memoizeThunk -> expandWorldMap(mapDef)

