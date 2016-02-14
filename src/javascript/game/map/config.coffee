TileHeight = 16
TileWidth  = 16
RoomWidth  = 16
RoomHeight = 15

Config =
  tileWidth:  TileWidth
  tileHeight: TileHeight
  roomWidth:  RoomWidth
  roomHeight: RoomHeight
  roomHeightInPixels:  RoomHeight * TileHeight
  roomWidthInPixels:   RoomWidth * TileWidth
  screenWidthInTiles:  RoomWidth
  screenHeightInTiles: RoomHeight

module.exports = Config
