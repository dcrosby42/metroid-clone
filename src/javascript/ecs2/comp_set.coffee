
module.exports = class CompSet
  constructor: (@initSize=20,@growSize=10,@name) ->
    @comps = new Array(@initSize)
    @iterbuf = new Array(@initSize)
    @iterbufInvalid = true
    for _,i in @comps
      @comps[i] = null
      # @iterbuf[i] = null
    @length = @initSize
    @count = 0
    @ect = 0

  add: (comp) ->
    if @count < @length
      for c,i in @comps
        if !c?
          @comps[i] = comp
          @count++
          break
    else
      # Full. Grow!
      newLen = @length + @growSize
      # console.log "CompSet #{@name}: growing from #{@length} to #{newLen}"
      upsized = new Array(newLen)
      for c,i in @comps
        upsized[i] = c
      # console.log "  CompSet: upsized A",upsized
      upsized[@length] = comp
      # console.log "  CompSet: upsized B",upsized
      @count++
      i = @length+1
      while i < newLen
        upsized[i] = null
        i++
      @comps = upsized
      @length = newLen
    @iterbufInvalid = true

  each: (fn) ->
    count = @count
    if @ect == 0
      if @iterbufInvalid
        if @iterbuf.length < count
          @iterbuf = new Array(@length)
        i = 0
        while i < count
          for c in @comps
            if c?
              @iterbuf[i] = c
              console.log "  >> @iterbuf[#{i}] <-",c
              i++
        @iterbufInvalid = false

    @ect++
    

    i = 0
    while i < count
      fn(@iterbuf[i])
      i++

    ## local iterbuf copy:
    # console.log "CompSet(#{@name}).each ect=#{@ect}"
    # iterbuf = new Array(@count)
    # n=0
    # for c,i in @comps
    #   if c?
    #     iterbuf[i] = c
    #     n++
    #     break if n >= @count
    #
    # for c in iterbuf
    #   fn(c)

    ## orig:
    # for c in @comps
    #   if c?
    #     fn(c)

    @ect--
    null

  # _prepIterbuf: ->
  #   if @iterbuf.length < @count
  #     @iterbuf = new Array(@length)
  #   n = 0
  #   for c,i in @comps
  #     if c?
  #       @iterbuf[i] = c
  #       n++
  #       if n >= @count
  #         break

  single: ->
    for c in @comps
      if c?
        if @count != 1
          console.log "!! WARNING CompSet#single on NON-singleton list; returning component 1 of #{@count}",c
        return c

    console.log "!! WARNING CompSet#single returning null"
    return null

  # getByCid: (cid) ->
  #   for c in @comps
  #     if c? and c.cid == cid
  #       return c

  deleteByCid: (cid) ->
    for c,i in @comps
      if c? and c.cid == cid
        @comps[i] = null
        @count -= 1
        @iterbufInvalid = true
