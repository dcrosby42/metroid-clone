MyBench = require './my_bench'

Immutable = require 'immutable'

bench = new MyBench("Map value iteration")

bench.setup (ctx) ->
  map = Immutable.Map()
  data = []
  for i in [1..100]
    x = Math.random()
    data.push x
    map = map.set("key-#{x}",x)

  list = Immutable.List(data)
  seq = Immutable.Seq(data)
  set = Immutable.Set(data)

  ctx.list = list
  ctx.seq = seq
  ctx.set = set
  ctx.map = map

  ctx.listSeq = Immutable.Seq(list.toArray())
  ctx.setSeq = Immutable.Seq(set.toArray())
  ctx.mapSeq = Immutable.Seq(map.toArray())

  # console.log ctx.seq
  # console.log ctx.listSeq
  # console.log ctx.setSeq
  # console.log ctx.mapSeq

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

bench.add "list.map()", (ctx) ->
  ctx.list.map (x) ->
    ctx.doWork(x)

bench.add "listSeq iter", (ctx) ->
  seq = ctx.listSeq
  i = 0
  while i < seq.size
    ctx.doWork(seq.get(i))
    i++


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

bench.add "seq.map()", (ctx) ->
  ctx.seq.map (x) ->
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

bench.add "set.map() iter", (ctx) ->
  ctx.set.map (x) ->
    ctx.doWork(x)

bench.add "setSeq iter", (ctx) ->
  seq = ctx.setSeq
  i = 0
  while i < seq.size
    ctx.doWork(seq.get(i))
    i++


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

bench.add "map.map()", (ctx) ->
  ctx.map.map (x) ->
    ctx.doWork(x)

bench.add "mapSeq iter", (ctx) ->
  seq = ctx.setSeq
  i = 0
  while i < seq.size
    ctx.doWork(seq.get(i))
    i++

bench.run()
