class UIConfig
  constructor: ({spriteConfigs, mapDatabase}) ->
    @_spriteConfigs = spriteConfigs
    @_mapDatabase = mapDatabase

    @_viewportConfigs = {}

  getSpriteConfig: (name) ->
    @_spriteConfigs[name]

  getMapDatabase: -> @_mapDatabase

  getViewportConfig: (mapName) ->
    cfg = @_viewportConfigs[mapName]
    unless cfg?
      map = @_mapDatabase.get(mapName)
      cfg = @_setupViewportConfig(map)
      @_viewportConfigs[mapName] = cfg
    cfg

  _setupViewportConfig: (map) ->
   config =
     layerName: "base"
     minX: 0
     maxX: (map.tileGrid[0].length - map.screenWidthInTiles) * map.tileWidth
     minY: 0
     maxY: (map.tileGrid.length - map.screenHeightInTiles) * map.tileHeight
     trackBufLeft: 7 * map.tileWidth
     trackBufRight: 9 * map.tileWidth
     trackBufTop: 7 * map.tileHeight
     trackBufBottom: 9 * map.tileHeight
   config

  @create: (a...) -> new @(a...)

module.exports = UIConfig

