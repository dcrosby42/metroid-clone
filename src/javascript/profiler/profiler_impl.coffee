MathUtils = require '../utils/math_utils'

class ProfilerImpl
  constructor: (@stopWatch) ->
    @reset()

  reset: ->
    @times = {}
    @counts = {}
    @samples = {}

  in: (name) ->
    @times[name] ?= []
    @times[name].push @stopWatch.currentTimeMillis()
    null

  out: (name) ->
    arr = @times[name]
    l = arr.count
    arr[l-1] = @stopWatch.currentTimeMillis - arr[l-1]
    null

  count: (name) ->
    @counts[name] ?= 0
    @counts[name] += 1

  sample: (name,x) ->
    @samples[name] ?= []
    @samples[name].push x

  tear: (item={}) ->
    for key,arr of @times
      item[key] =
        count: arr.length
        sum: MathUtils.arraySum(arr)
        mean: MathUtils.arrayMean(arr)
        min: MathUtils.arrayMin(arr)
        max: MathUtils.arrayMax(arr)

    for key,c of @counts
      item[key] =
        count: c

    for key,arr of @samples
      item[key] =
        count: arr.length
        sum: MathUtils.arraySum(arr)
        mean: MathUtils.arrayMean(arr)
        min: MathUtils.arrayMin(arr)
        max: MathUtils.arrayMax(arr)


    @reset()
    item

module.exports = ProfilerImpl
