C = require '../../components'
T = C.Types

exports.buildComp = C.buildCompForType

exports.tag = (t) ->
  exports.buildComp T.Tag, name: t


exports.name = (t) ->
  exports.buildComp T.Name, name: t
