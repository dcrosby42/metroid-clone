ConstA = 16807
ConstB = 2147483647

next = (state) -> state = (state * ConstA) % ConstB

nextInt = (state, min, max) ->
  state1 = next(state)
  res = Math.round((min + ((max - min) * state1 / 2147483647.0)))
  return [res,state1]

choose = (state,list) ->
  [i,state1] = nextInt(state, 0, list.length - 1)
  return [list[i], state1]

weightedChoose = (state,list) ->
  total_weight = 0
  for [value, weight] in list
    total_weight += weight

  [target_weight,state1] = nextInt(state, 0, total_weight)
  current_weight = 0
  for [value, weight] in list
    # this seems silly, but I couldn't think of a simpler way
    #   off the top of my head
    next_weight = current_weight + weight
    if (target_weight <= (weight + current_weight))
      return [value, state1]
    current_weight = next_weight

module.exports =
  next: next
  nextInt: nextInt
  choose: choose
  weightedChoose: weightedChoose

