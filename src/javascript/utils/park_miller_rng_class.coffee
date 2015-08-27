class ParkMillerRNG
  constructor: (@seed) ->
    @gen()
  gen: -> @seed = (@seed * 16807) % 2147483647
  nextInt: (min, max) ->
    Math.round((min + ((max - min) * @gen() / 2147483647.0)))
  choose: (list) ->
    i = @nextInt(0, list.length - 1)
    list[i]
  weighted_choose: (list) ->
    total_weight = 0
    for [value, weight] in list
      total_weight += weight

    target_weight = @nextInt(0, total_weight)
    current_weight = 0
    for [value, weight] in list
      # this seems silly, but I couldn't think of a simpler way
      #   off the top of my head
      next_weight = current_weight + weight
      if (target_weight <= (weight + current_weight))
        return value
      current_weight = next_weight


module.exports = ParkMillerRNG
