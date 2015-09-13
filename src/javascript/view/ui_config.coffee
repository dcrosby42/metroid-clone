class UIConfig
  constructor: ({spriteConfigs, mapDatabase}) ->
    @_spriteConfigs = spriteConfigs
    @_mapDatabase = mapDatabase # XXX ?

  getSpriteConfig: (name) ->
    @_spriteConfigs[name]

# XXX  getMapDatabase: -> @_mapDatabase

  @create: (a...) -> new @(a...)

module.exports = UIConfig

