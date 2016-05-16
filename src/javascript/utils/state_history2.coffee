Immutable = require 'immutable'
{Map,List} = Immutable

StateHistory =
  empty: Map
    maxSize: (5*60),
    data: List(),
    index: 0

  current: (sh) ->
    sh.get('data').get(sh.get('index'))

  size: (sh) ->
    sh.get('data').size

  add: (sh,x) ->
    d = sh.get('data')
    d = d.push(x)
    while d.size > sh.get('maxSize')
      d = d.shift()
    i = d.size - 1
    sh.set('data',d).set('index',i)

  forward: (sh) ->
    sh.update 'index', (i) ->
      i += 1
      limit = sh.get('data').size - 1
      i = limit if i > limit
      i

  back: (sh) ->
    sh.update 'index', (i) ->
      i -= 1
      i = 0 if i < 0
      i

  indexTo: (sh,i) ->
    i = 0 if i < 0
    max = sh.get('data').size-1
    i = max if i > max
    sh.set('index',i)

  indexToStart: (sh) ->
    sh.set('index',0)

  indexToEnd: (sh) ->
    sh.set('index',sh.get('data').size-1)

  truncate: (sh) ->
    d = sh.get('data')
    i = sh.get('index')
    while d.size > i+1
      d = d.pop()
    sh.set('data',d)

    
module.exports = StateHistory
