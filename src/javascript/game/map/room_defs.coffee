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

_itemId = 1
nextItemId = ->
  id = _itemId
  _itemId += 1
  return id

newRoomDef = (id,rd) ->
  unless rd?
    console.log "!! RoomDefs.mkRoomDef got id=#{id}, rd=#{rd}"
    return
  grid = expandChunks(rd.chunks)
  roomDef = new Types.RoomDef
    id: id
    grid: expandChunks(rd.chunks)
    items: rd.items || []
    fixtures: rd.fixtures || []
    enemies: rd.enemies || []

  # Mutate the item defs by giving each a unique ID
  for item in roomDef.items
    unless item.id?
      item.id = "item-#{nextItemId()}"

  return roomDef


class Cache
  constructor: (@data,@builder) ->
    @cache = {}
  get: (id) ->
    @cache[id] ?= @builder(id,@data[id])


module.exports = new Cache(RoomData, newRoomDef)
