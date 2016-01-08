class UIConfig
  constructor: ({spriteConfigs, worldMap}) ->
    @_spriteConfigs = spriteConfigs
    @_worldMap = worldMap

  getSpriteConfig: (name) ->
    @_spriteConfigs[name]

  getRoom: (roomId) ->
    @_worldMap.getRoomById(roomId)

  @create: (a...) -> new @(a...)

module.exports = UIConfig

