TileMap = require './tile_map'
MapData = require './map_data'

class MapDatabase
  constructor: (@mapData) ->
    @tileMaps = {}

  get: (mapName) ->
    map = @tileMaps[mapName]
    unless map?
      data = @mapData[mapName]
      unless data?
        console.log "!! MapDatabase: map data doesn't contain '#{mapName}'", @mapData
      map = TileMap.create(data,mapName)
      @tileMaps[mapName] = map
    return map

  @createDefault: ->
    new @(MapData.areas)


module.exports = MapDatabase

