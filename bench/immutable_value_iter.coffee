MyBench = require './my_bench'

Immutable = require 'immutable'

bench = new MyBench("Map value iteration")

bench.setup (ctx) ->
  map = Immutable.Map()
  data = []
  for x in [1..100]
    data.push x
    map = map.set("key-#{x}",x)

  list = Immutable.List(data)
  seq = Immutable.Seq(data)
  set = Immutable.Set(data)

  ctx.list = list
  ctx.seq = seq
  ctx.set = set
  ctx.map = map
  ctx.doWork = (x) -> x + 1

bench.add "list.values() iter", (ctx) ->
  iter = ctx.list.values()
  x = iter.next()
  while !x.done
    ctx.doWork(x.value)
    x = iter.next()

bench.add "list.valueSeq() iter", (ctx) ->
  seq = ctx.list.valueSeq()
  i = 0
  while i < seq.size
    ctx.doWork(seq.get(i))
    i++

bench.add "list.forEach() iter", (ctx) ->
  ctx.list.forEach (x) ->
    ctx.doWork(x)



bench.add "seq.values() iter", (ctx) ->
  iter = ctx.seq.values()
  x = iter.next()
  while !x.done
    ctx.doWork(x.value)
    x = iter.next()

bench.add "seq straight", (ctx) ->
  seq = ctx.seq
  i = 0
  while i < seq.size
    ctx.doWork(seq.get(i))
    i++

bench.add "seq.forEach() iter", (ctx) ->
  ctx.seq.forEach (x) ->
    ctx.doWork(x)


bench.add "set.values() iter", (ctx) ->
  iter = ctx.set.values()
  x = iter.next()
  while !x.done
    ctx.doWork(x.value)
    x = iter.next()

bench.add "set.valueSeq() iter", (ctx) ->
  seq = ctx.set.valueSeq()
  i = 0
  while i < seq.size
    ctx.doWork(seq.get(i))
    i++

bench.add "set.forEach() iter", (ctx) ->
  ctx.set.forEach (x) ->
    ctx.doWork(x)

bench.add "map.values() iter", (ctx) ->
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
