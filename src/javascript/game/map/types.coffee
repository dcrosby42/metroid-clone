class exports.TileDef
  constructor: ({@id}) ->

class exports.RoomDef
  constructor: ({@id,@grid,@items,@enemies,@fixtures}) ->
  # @stuff? @stuff.items etc. dynamically indexed "components" of whatever.

# # # # #

class exports.World
  constructor: ({@zones}) ->

class exports.Zone
  constructor: ({@id,@areas,@music,@rooms,@tiles}) ->

class exports.Area
  constructor: ({@name,@rooms,@bounds,@rowColBounds,@zone,@music}) ->

class exports.Room
  constructor: ({@id,@roomDef,@row,@col,@x,@y,@tiles,@area}) ->

class exports.Tile
  constructor: ({@x,@y,@worldX,@worldY,@row,@col,@worldRow,@worldCol,@room,@type,@width,@height}) ->
