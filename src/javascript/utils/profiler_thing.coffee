MathUtils = require './math_utils'

class ProfilerThing
  constructor: (@stopWatch) ->
    @collect = {}
    # @results = []

  in: (name) ->
    @collect[name] ?= []
    @collect[name].push @stopWatch.currentTimeMillis()
    null

  out: (name) ->
    arr = @collect[name]
    l = arr.count
    arr[l-1] = @stopWatch.currentTimeMillis - arr[l-1]
    null

  tear: (item={}) ->
    for key,arr of @collect
      item[key] =
        count: arr.length
        sum: MathUtils.sum(arr)
        mean: MathUtils.mean(arr)
    @collect = {}
    # @results.push item
    item

module.exports = ProfilerThing
