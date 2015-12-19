Immutable = require 'immutable'

mkArray = (size,val) -> (val for [1..size])
mkList = (size,val) -> Immutable.List(mkArray(size,val))

ringInc = (i,maxSize) ->
  i += 1
  if i >= maxSize
    i = 0
  i

ringDec = (i,maxSize) ->
  i -= 1
  if i < 0
    i = maxSize-1
  i

create = (maxSize) ->
  if !maxSize? || maxSize <= 0
    throw new Error("ImmRingBuffer must be maxSize > 0")
  Immutable.Map
      maxSize: maxSize
      read: -1
      write: 0
      tail: maxSize-1
      data: mkList(maxSize,null)

clear = (buf) ->
  create(buf.get('maxSize'))

readAt = (buf,i) ->
  buf.get('data').get(i)

readCurrent = (buf) ->
  readAt(buf, buf.get('read'))

forward = (buf) ->
  return buf if isEmpty(buf)
  read = ringInc(buf.get('read'),buf.get('maxSize'))
  if read != buf.get('write')
    buf.set('read',read)
  else
    buf

backward = (buf) ->
  return buf if isEmpty(buf)
  read = buf.get('read')
  if read != buf.get('tail')
    read = ringDec(read,buf.get('maxSize'))
    buf.set('read',read)
  else
    buf

isAtHead = (buf) ->
  isEmpty(buf) or (ringInc(buf.get('read'),buf.get('maxSize')) == buf.get('write'))

isAtTail = (buf) ->
  isEmpty(buf) or (buf.get('read') == buf.get('tail'))

getData = (buf) ->
  buf.get('data')

isEmpty = (buf) ->
  buf.get('read') == -1

truncate = (buf) ->
  return buf if isEmpty(buf)
  buf.set 'write', ringInc(buf.get('read'),buf.get('maxSize'))

add = (buf, item) ->
  maxSize = buf.get('maxSize')
  write = buf.get('write')
  tail = buf.get('tail')
  buf = buf.setIn(['data',write], item)
  if write == tail
    tail = ringInc(tail,maxSize)
    buf = buf.set 'tail', tail
  write = ringInc(write,maxSize)
  buf = buf.set 'write', write
  buf = buf.set 'read', ringDec(write,maxSize)
  buf


ImmRingBuffer =
  create: create
  add: add
  read: readCurrent
  isEmpty: isEmpty
  isAtHead: isAtHead
  isAtTail: isAtTail
  forward: forward
  backward: backward
  truncate: truncate
  clear: clear
  sneakAPeek: getData
  






module.exports = ImmRingBuffer
