# MapData = require './map_data'
#
# class TileMap
#   constructor: ({@name, @tileGrid, @tileWidth, @tileHeight, @screenWidthInTiles, @screenHeightInTiles}) ->
#
#   @create: (map,name) ->
#     # TODO: move these info/consts into this class/file?
#     mapTileHeight = MapData.info.tileHeight
#     mapTileWidth = MapData.info.tileWidth
#     roomWidth = MapData.info.screenWidthInTiles
#     roomHeight = MapData.info.screenHeightInTiles
#
#     divRem = (numer,denom) -> [Math.floor(numer/denom), numer % denom]
#
#     mapRowCount = map.length * roomHeight
#     mapColCount = map[0].length * roomWidth
#
#     tileGrid = []
#     for r in [0...mapRowCount]
#       tileRow = []
#       tileGrid.push tileRow
#       for c in [0...mapColCount]
#         [rr,tr] = divRem(r, roomHeight)
#         [rc,tc] = divRem(c, roomWidth)
#         roomType = map[rr][rc]
#         room = MapData.roomTypes[roomType]
#         tileType = room[tr][tc]
#         if tileType?
#           tile =
#             type: tileType
#             x: c * mapTileWidth
#             y: r * mapTileHeight
#             width: mapTileWidth
#             height: mapTileHeight
#           
#           tileRow.push tile
#         else
#           tileRow.push null
#
#     name ?= "A Map"
#     return new @(
#       name: name
#       tileGrid: tileGrid
#       tileWidth: mapTileWidth
#       tileHeight: mapTileHeight
#       screenWidthInTiles: roomWidth
#       screenHeightInTiles: roomHeight
#     )
#
# module.exports = TileMap
#
