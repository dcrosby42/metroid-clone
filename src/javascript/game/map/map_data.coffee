RoomDefs = require './room_defs'
ChunkDefs = require './chunk_defs'

RoomWidth = 16
RoomHeight = 15

roomTypes = []

roomTypes[0] = [
  [ 0x01,0x01,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x01,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x01,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
        
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,null,0x00,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,null,0x00,null, null,null,0x00,0x00, null,null,null,null, null,null,null,null ]
  [ 0x00,null,0x00,0x00, null,null,null,null, null,null,null,null, null,null,null,null ]
        
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,0x00,null ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,0x00,null ]
  [ 0x00,0x00,null,null, null,0x00,null,null, null,null,null,null, null,null,0x00,null ]
  [ 0x00,null,null,null, null,0x00,null,null, null,null,null,null, 0x00,null,0x00,null ]
        
  [ 0x00,null,0x00,null, null,0x00,null,null, null,null,null,null, null,null,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
]

roomTypes[1] = [
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]

  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]

  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]

  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
]


roomTypes[2] = [
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]

  [ null,null,null,null, null,null,null,null, null,null,0x00,null, 0x00,null,0x00,0x00 ]
  [ null,null,0x00,null, null,0x00,null,null, null,null,0x00,null, 0x00,null,0x00,0x00 ]
  [ null,null,0x00,null, null,0x00,0x00,0x00, null,null,0x00,0x00, 0x00,null,0x00,0x00 ]
  [ 0x00,null,0x00,0x00, 0x00,null,null,null, null,null,null,null, null,null,0x00,0x00 ]

  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,0x00,0x00 ]
  [ null,null,null,null, null,null,null,null, 0x00,0x00,0x00,null, null,null,0x00,0x00 ]
  [ null,0x00,null,null, null,0x00,null,null, null,0x00,0x00,null, null,null,0x00,0x00 ]
  [ null,null,null,null, null,0x00,null,null, null,null,null,null, 0x00,null,0x00,0x00 ]

  [ null,null,0x00,null, null,0x00,null,null, null,null,null,null, null,null,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
]

roomTypes[3] = [
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,0x00,0x00,0x00, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,0x00,0x00,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
]

roomTypes[4] = [
  [ 0x00,null,null,null, null,null,null,null, null,0x00,0x00,0x00, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, 0x00,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, 0x00,0x00,0x00,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,0x00,0x00,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ null,null,null,null, null,null,null,null, null,0x00,0x00,0x00, null,null,null,null ]
  [ null,null,null,0x00, 0x00,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ null,null,null,null, null,null,null,null, null,null,null,null, null,null,null,null ]
  [ 0x00,0x00,null,null, null,null,null,null, null,null,null,null, 0x00,0x00,0x00,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,0x00, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, 0x00,0x00,null,null, null,null,null,0x00 ]
]

roomTypes[5] = [
  [ 0x00,null,0x00,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, 0x00,0x00,0x00,null, null,null,null,0x00 ]
  [ 0x00,0x00,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,0x00, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,0x00,0x00,0x00, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, 0x00,null,null,null, null,null,null,null, 0x00,0x00,0x00,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,0x00, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,0x00,0x00, 0x00,0x00,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
]

roomTypes[6] = [
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, 0x00,0x00,0x00,0x00, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, 0x00,0x00,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,null,null,null, null,null,null,null, null,null,null,null, null,null,null,0x00 ]
  [ 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00 ]
]

emptyGrid = -> ((null for [1..RoomWidth]) for [1..RoomHeight])

expandChunkInto = (grid, colOff,rowOff, chunkDef) ->
  for row, ri in chunkDef
    r = ri + rowOff
    if r >= 0 and r < RoomHeight
      for t,ci in row
        c = ci + colOff
        if c >= 0 and c < RoomWidth
          grid[r][c] = t
  

expandRoomDef = (roomDef) ->
  grid = emptyGrid()
  for [x,y,ch] in roomDef.chunks
    expandChunkInto(grid, x,y, ChunkDefs[ch])
  grid

for roomDef,i in RoomDefs
  if roomDef?
    roomTypes[i] = expandRoomDef(roomDef)

######################################################################
areas = {}

areas.areaA = [
  [ 0, 1, 2]
]

areas.areaB = [
  [3]
  [4]
  [5]
]

areas.areaC = [
  [3,3]
  [4,4]
  [4,4]
  [5,5]
]

areas.zoomerTest = [
  [6]
]

areas.mapTest = [
  [0x12, 0x14, 0x19, 0x13]
]

exports.roomTypes = roomTypes
exports.areas = areas
exports.info =
  tileWidth: 16
  tileHeight: 16
  screenWidthInTiles: RoomWidth
  screenHeightInTiles: RoomHeight

exports.roomDefs = RoomDefs
