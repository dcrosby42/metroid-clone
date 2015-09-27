class UIConfig
  constructor: ({spriteConfigs, worldMap, mapDatabase}) ->
    @_spriteConfigs = spriteConfigs
    @_worldMap = worldMap
    @_mapDatabase = mapDatabase # XXX ?

  getSpriteConfig: (name) ->
    @_spriteConfigs[name]

  getRoom: (roomId) ->
    @_worldMap.getRoomById(roomId)

  @create: (a...) -> new @(a...)

module.exports = UIConfig

