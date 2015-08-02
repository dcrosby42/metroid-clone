endsWithPressedOrReleased = /(Pressed|Released)$/
updatePressedReleased = (s, input) ->
  s1 = s.reduce (map, x, key) ->
    if key.match endsWithPressedOrReleased
      map.delete(key)
    else
      map
  , s

  input.reduce (map, val, key) ->
    kp = "#{key}Pressed"
    kr = "#{key}Released"
    map2 = if val and !map.get(key)
      map.set(kp, true)
    else
      map.delete(kp)

    map3 = if !val and map.get(key)
      map2.set(kr, true)
    else
      map2.delete(kr)

    map3.set(key,val)

  , s1

module.exports =
  update: updatePressedReleased
