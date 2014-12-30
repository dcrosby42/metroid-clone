PIXI = require 'pixi.js'
WallSpritesPool = require './wall_sprites_pool'
SliceType = require './slice_type'
WallSlice = require './wall_slice'

class Walls extends PIXI.DisplayObjectContainer
  @VIEWPORT_WIDTH: 512
  @VIEWPORT_NUM_SLICES: Math.ceil(Walls.VIEWPORT_WIDTH/WallSlice.WIDTH) + 1

  constructor: ->
    super
    @pool = new WallSpritesPool()
    @createLookupTables()
    @slices = []

    @viewportX = 0
    @viewportSliceX = 0
    
  createLookupTables: ->
    bfs = []
    bfs[SliceType.FRONT] = @pool.borrowFrontEdge
    bfs[SliceType.BACK] = @pool.borrowBackEdge
    bfs[SliceType.STEP] = @pool.borrowStep
    bfs[SliceType.DECORATION] = @pool.borrowDecoration
    bfs[SliceType.WINDOW] = @pool.borrowWindow
    @borrowWallSpriteLookup = bfs

    rfs = []
    rfs[SliceType.FRONT] = @pool.returnFrontEdge
    rfs[SliceType.BACK] = @pool.returnBackEdge
    rfs[SliceType.STEP] = @pool.returnStep
    rfs[SliceType.DECORATION] = @pool.returnDecoration
    rfs[SliceType.WINDOW] = @pool.returnWindow
    @returnWallSpriteLookup = rfs

  borrowWallSprite: (sliceType) ->
    @borrowWallSpriteLookup[sliceType].call(@pool)

  returnWallSprite: (sliceType,sprite) ->
    @returnWallSpriteLookup[sliceType].call(@pool, sprite)

  addSlice: (sliceType, y) ->
    slice = new WallSlice(sliceType, y)
    @slices.push slice

  setViewportX: (x) ->
    @viewportX = @checkViewportXBounds(x)
    prevViewportSliceX = @viewportSliceX
    @viewportSliceX = Math.floor(@viewportX/WallSlice.WIDTH)
    @removeOldSlices(prevViewportSliceX)
    @addNewSlices()

  checkViewportXBounds: (x) ->
    maxViewportX = (@slices.length - Walls.VIEWPORT_NUM_SLICES) * WallSlice.WIDTH

    if x < 0
      x = 0
    else if x >= maxViewportX
      x = maxViewportX

    x

  addNewSlices: ->
    firstX = -(@viewportX % WallSlice.WIDTH)
    sliceIndex = 0
    for i in [@viewportSliceX...@viewportSliceX+Walls.VIEWPORT_NUM_SLICES]
      # console.log "i=#{i}, sliceIndex=#{sliceIndex}"
      slice = @slices[i]
      if slice and slice.sprite == null && slice.type != SliceType.GAP
        # populate the sprite and move the sprite
        s = @borrowWallSprite(slice.type)
        if s?
          s.position.x = firstX + (sliceIndex*WallSlice.WIDTH)
          s.position.y = slice.y
          slice.sprite = s
          # console.log "FAILED TO BORROW WALL SPRITE @viewportSliceX=#{@viewportSliceX}"

          @addChild(slice.sprite)

      else if slice and slice.sprite != null
        # just update sprite x pos
        slice.sprite.position.x = firstX + (sliceIndex*WallSlice.WIDTH)
      sliceIndex += 1
        
  removeOldSlices: (prevViewportSliceX) ->
    numOldSlices = @viewportSliceX - prevViewportSliceX
    if numOldSlices > Walls.VIEWPORT_NUM_SLICES
      numOldSlices = Walls.VIEWPORT_NUM_SLICES

    for i in [prevViewportSliceX...prevViewportSliceX+numOldSlices]
      slice = @slices[i]
      if slice and slice.sprite?
        @returnWallSprite(slice.type, slice.sprite)
        @removeChild(slice.sprite)
        slice.sprite = null

module.exports = Walls

