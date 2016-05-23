endsWithPressedOrReleased = /(Pressed|Released)$/
updatePressedReleased = (s, input) ->
  s = s.reduce (map, x, key) ->
    if key.match endsWithPressedOrReleased
      map.delete(key)
    else
      map
  , s

  if input
    input.reduce (map, val, key) ->
      prevVal = map.get(key)
      if val
        map = map.set(key,val)
        if !prevVal
          map = map.set("#{key}Pressed", true)
        map
      else
        map = map.delete(key)
        if prevVal
          map = map.set("#{key}Released", true)
        map
    , s
  else
    s

module.exports =
  update: updatePressedReleased
