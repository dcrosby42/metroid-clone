_ = require 'lodash'

clamp = (x,min,max) ->
  if x < min
    min
  else if x > max
    max
  else
    x

min = (a,b) -> if b < a then b else a

max = (a,b) -> if b > a then b else a

keepWithin = (x,target,minDist,maxDist) ->
  if target - x < minDist # move left to preserve min dist:
    return target - minDist
  else if target - x > maxDist # move right to stay within max dist:
    return target - maxDist
  x # x is already at comfortable distance to target

divRem = (numer,denom) -> [Math.floor(numer/denom), numer % denom]

arraySum = (arr) ->
  _.sum(arr)
  # s = 0
  # for x in arr
  #   s += x
  # s

arrayMin = (arr) ->
  _.min(arr)

arrayMax = (arr) ->
  _.max(arr)

arrayMean = (arr) ->
  _.sum(arr) / arr.length

module.exports =
  min: min
  max: max
  arraySum: arraySum
  arrayMax: arrayMax
  arrayMin: arrayMin
  arrayMean: arrayMean
  clamp: clamp
  keepWithin: keepWithin
  divRem: divRem

