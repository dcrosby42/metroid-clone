microtime = require 'microtime'

benches = []

addBench = (desc,f) ->

millisecond = 1000
second = 1000 * millisecond

class MyBench
  constructor: (@desc) ->
    @benches = []

  setup: (@setupFn) ->

  add: (desc,f) ->
    @benches.push
      desc: desc
      f: f

  run: (numSeconds=1.0) ->
    context = {}
    @setupFn(context)

    timeLimit = numSeconds * second
    for bench in @benches
      start = microtime.now()
      todo = true
      ct = 0
      while todo
        bench.f(context)
        ct++
        todo = (microtime.now() - start < timeLimit)
      elapsed = microtime.now()-start
      console.log "#{bench.desc}: #{ct} loops in #{elapsed/second}s"
    context

module.exports = MyBench
