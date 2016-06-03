fill = (arr,fillFn,start,size) ->
  i = start
  end = start+size
  while i < end
    arr[i] = fillFn()
    i++

class Ring
  constructor: (@initSize,@growSize,@fillFn) ->
    @data = new Array(@initSize)
    fill(@data,@fillFn,0,@initSize)
    @length = @data.length
    @count = @length
    @head = 1
    @tail = 0

  take: ->
    if @count == 0
      if !@_grow()
        console.log "EMPY!"
        return null
    item = @data[@head]
    @data[@head] = null
    @count--
    @head++
    if @head >= @length
      @head = 0
    return item

  put: (item) ->
    if @count == @length
      console.log "FUL!"
      return null
    @tail++
    if @tail >= @length
      @tail = 0
    @data[@tail] = item
    @count++
    return null

  _grow: ->
    newLen = @length + @growSize
    @data = new Array(newLen)
    fill(@data, @fillFn, @length,@growSize)
    @head = 0
    @tail = @length
    @length = newLen
    @count = @growSize
    return true

vec2 = ->
  console.log ">> new vec2!"
  [0.0,0.0]
r = new Ring(5,10,vec2)
# console.log r
for i in [0...7]
  console.log "\n\ti = #{i}\n"
  p = r.take()
  if p?
    p[0] = i
    p[1] = i
  else
    console.log "No pos returned from ring @ i=#{i}"
  # console.log p
  # r.put(p)
  console.log r

    
