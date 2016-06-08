endsWithPressedOrReleased = /(Pressed|Released)$/

updatePressedReleased = (states, input) ->
  for key,val of states
    if !val or key.match endsWithPressedOrReleased
      delete states[key]

  if input?
    for key,val of input
      prevVal = states[key]
      if val
        states[key] = val
        if !prevVal
          states["#{key}Pressed"] = true
      else
        delete states[key]
        if prevVal
          states["#{key}Released"] = true

  states
  

module.exports =
  update: updatePressedReleased
