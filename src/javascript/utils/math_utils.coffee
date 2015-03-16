clamp = (x,min,max) ->
  if x < min
    min
  else if x > max
    max
  else
    x

min = (a,b) -> if b < a then b else a

max = (a,b) -> if b > a then b else a

module.exports =
  max: max
  min: min
  clamp: clamp
