# General = require('./components')
Common = require('../components')
Immutable = require('immutable')

F = {}

F.backgroundMusic = (args) ->
  [
    Immutable.Map(type: 'background_music')
    Common.Name.merge(name: "BG Music")
    Common.Sound.merge
      soundId: args.music
      volume: args.volume
      loop:true
      timeLimit: args.timeLimit
  ]

module.exports =
  createComponents: (entityType, args) ->
    F[entityType](args)

