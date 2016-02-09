RoomDefs = require './room_defs'
ChunkDefs = require './chunk_defs'

RoomWidth = 16
RoomHeight = 15

roomTypes = []

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
exports.roomTypes = roomTypes
exports.info =
  tileWidth: 16
  tileHeight: 16
  screenWidthInTiles: RoomWidth
  screenHeightInTiles: RoomHeight

exports.roomDefs = RoomDefs
