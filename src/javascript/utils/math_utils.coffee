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

sum = (arr) ->
  s = 0
  for x in arr
    s += x
  s

mean = (arr) ->
  sum(arr) / arr.length


module.exports =
  max: max
  min: min
  clamp: clamp
  keepWithin: keepWithin
  divRem: divRem
  sum: sum
  mean: mean

