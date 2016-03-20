MyBench = require './my_bench'

Immutable = require 'immutable'

bench = new MyBench("Map value iteration")

bench.setup (ctx) ->
  map = Immutable.Map()
  for x in [1..100]
    map = map.set("key-#{x}",x)

  ctx.map = map
  ctx.doWork = (x) -> x + 1

bench.add "values() iter", (ctx) ->
  iter = ctx.map.values()
  x = iter.next()
  while !x.done
    ctx.doWork(x.value)
    x = iter.next()

bench.add "map.valueSeq() iter", (ctx) ->
  seq = ctx.map.valueSeq()
  i = 0
  while i < seq.size
    ctx.doWork(seq.get(i))
    i++

bench.add "map.forEach() iter", (ctx) ->
  ctx.map.forEach (x) ->
    ctx.doWork(x)


bench.run()
