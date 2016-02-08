exports.memoizeThunk = (fn) ->
  result = null
  -> result ?= fn()


