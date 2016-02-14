Config = require './config'
RoomData = require './room_data'
ChunkData = require './chunk_data'
Types = require './types'

emptyGrid = (rows,cols) -> ((null for [1..cols]) for [1..rows])

expandChunkInto = (grid, colOff,rowOff, chunk) ->
  for row, ri in chunk
    r = ri + rowOff
    if r >= 0 and r < Config.roomHeight
      for t,ci in row
        c = ci + colOff
        if c >= 0 and c < Config.roomWidth
          grid[r][c] = t

expandChunks = (chunks) ->
  grid = emptyGrid(Config.roomHeight,Config.roomWidth)
  for [x,y,ch] in chunks
    expandChunkInto(grid, x,y, ChunkData[ch])
  grid

newRoomDef = (id,rd) ->
  unless rd?
    console.log "!! RoomDefs.mkRoomDef got id=#{id}, rd=#{rd}"
    return
  grid = expandChunks(rd.chunks)
  new Types.RoomDef
    id: id
    grid: expandChunks(rd.chunks)
    items: rd.items || []
    fixtures: rd.fixtures || []
    enemies: rd.enemies || []

class Cache
  constructor: (@data,@builder) ->
    @cache = {}
  get: (id) ->
    @cache[id] ?= @builder(id,@data[id])


module.exports = new Cache(RoomData, newRoomDef)
