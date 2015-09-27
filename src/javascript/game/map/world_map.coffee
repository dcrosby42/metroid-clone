TileSearch = require('./tile_search')
MapData = require('./map_data')
MathUtils = require('../../utils/math_utils')

emptyGrid = (rows,cols) -> ((null for [1..cols]) for [1..rows])

# Convert a grid of room types into a grid of room data objects
mapLayoutToRoomGrid = (mapLayout, roomTypes, roomDefs, roomWidthInTiles, roomHeightInTiles, tileWidth, tileHeight) ->

# Convert a grid of room types into a grid of room data objects
mapLayoutToRoomGrid = (mapLayout, roomTypes, roomWidthInTiles, roomHeightInTiles, tileWidth, tileHeight) ->
  roomGrid = emptyGrid(mapLayout.rows, mapLayout.cols)
  for row,r in mapLayout.data
    for roomType,c in row
      roomDef = roomDefs[roomType]
      enemies = if roomDef?
        roomDef.enemies
      room = Room.create(
        roomType:roomType
        row:r
        col:c
        x: c * roomWidthInTiles * tileWidth
        y: r * roomHeightInTiles * tileHeight
        tiles: tilesForRoom(roomTypes[roomType], tileWidth, tileHeight)
        enemies: enemies
      )
      roomGrid[r][c] = room
  roomGrid

# Convert a grid of tile types into a grid of tile data objects
tilesForRoom = (roomTiles, tileWidth, tileHeight) ->
  outRows = []
  for row,r in roomTiles
    outRow = []
    outRows.push outRow
    for tileType,c in row
      if tileType?
        tile =
          type: tileType
          x: c * tileWidth
          y: r * tileHeight
          width: tileWidth
          height: tileHeight
        outRow.push tile
      else
        outRow.push null
  outRows

roomGridToTileGrid = (roomGrid, roomTypes, roomWidthInTiles, roomHeightInTiles, tileWidth, tileHeight) ->
  mapRowCount = roomGrid.length * roomHeightInTiles
  mapColCount = roomGrid[0].length * roomWidthInTiles

  tileGrid = []
  for r in [0...mapRowCount]
    tileRow = []
    tileGrid.push tileRow
    for c in [0...mapColCount]
      [rr,tr] = MathUtils.divRem(r, roomHeightInTiles)
      [rc,tc] = MathUtils.divRem(c, roomWidthInTiles)
      room = roomGrid[rr][rc]
      if room? and room.roomType?
        roomTiles = roomTypes[room.roomType]
        tileType = roomTiles[tr][tc]
        if tileType?
          tile =
            type: tileType
            x: c * tileWidth
            y: r * tileHeight
            width: tileWidth
            height: tileHeight
          tileRow.push tile
        else
          tileRow.push null

  tileGrid


class Room
  constructor: ({@row,@col,@roomType,@x,@y,@tiles,@enemies}) ->
    @roomId = "room_r#{@row}_c#{@col}"

  id: -> @roomId

  @create: (info) -> new @(info)

# TODO: Areas!
class Area
  constructor: ({@top,@left,@right,@bottom}) ->
  leftPx: -> @left
  rightPx: -> @right
  topPx: -> @top
  bottomPx: -> @bottom

class WorldMap
  constructor: ({@roomGrid,@tileGrid,@tileWidth,@tileHeight,@roomWidthInTiles,@roomHeightInTiles}) ->
    @roomWidthInPx = @tileWidth * @roomWidthInTiles
    @roomHeightInPx = @tileHeight * @roomHeightInTiles
    @_tempArea = new Area # TODO Areas!
      top: 0 * @roomHeightInPx
      left: 0 * @roomWidthInPx
      right: 3 * @roomWidthInPx
      bottom: 0 * @roomHeightInPx
    @_roomsById = @_indexRoomGrid(@roomGrid)

  # Return an array of Rooms that overlap the given px rectangle
  searchRooms: (top,left,bottom,right) ->
    TileSearch.search2d(@roomGrid,@roomWidthInPx,@roomHeightInPx,top,left,bottom,right)

  getRoomById: (roomId) ->
    @_roomsById[roomId]

  # Return an array of tiles that overlap the given horizontal line
  tileSearchHorizontal: (y,left,right) ->
    TileSearch.searchHorizontal(@tileGrid, @tileWidth, @tileHeight, y, left, right)

  # Return an array of tiles that overlap the given verical line
  tileSearchVertical: (x,top,bottom) ->
    TileSearch.searchVertical(@tileGrid, @tileWidth, @tileHeight, x, top, bottom)

  # Return the Area containing the given px location
  searchArea: (top,left) ->
    # TODO: Areas!
    @_tempArea


  _indexRoomGrid: (roomGrid) ->
    index = {}
    for row in roomGrid
      for room in row
        if room?
          index[room.roomId] = room
    index

  @create: (layout) ->
    roomWidthInTiles = 16 # TODO: receive as params
    roomHeightInTiles = 15 # TODO: receive as params
    tileWidth = tileHeight = 16 # TODO: receive as params
    roomTypes = MapData.roomTypes
    roomDefs = MapData.roomDefs

    roomGrid = mapLayoutToRoomGrid(layout, roomTypes, roomWidthInTiles, roomHeightInTiles, tileWidth,tileHeight)
    tileGrid = roomGridToTileGrid(roomGrid, roomTypes, roomWidthInTiles, roomHeightInTiles, tileWidth,tileHeight)
    new @(
      roomGrid: roomGrid
      tileGrid: tileGrid
      tileHeight: tileHeight
      tileWidth: tileWidth
      roomWidthInTiles: roomWidthInTiles
      roomHeightInTiles: roomHeightInTiles
    )

defaultWorldMapLayout =
  rows: 10
  cols: 10
  data: [
    #roomA-----------------   roomB----------------------- 
    [0x12, 0x14, 0x19, 0x13,  0x12, 0x14, 0x14, 0x14, 0x13]
  ]
  areas: [
    ["roomA",[0,0],[0,3]]
    ["roomB",[0,4],[0,8]]
  ]

defaultWorldMap = null

module.exports =
  getDefaultWorldMap: ->
    defaultWorldMap ?= WorldMap.create(defaultWorldMapLayout)

