PIXI = require 'pixi.js'


mkSprite = (name, {flipX}={}) ->
  s = PIXI.Sprite.fromFrame(name)
  if flipX
    s.anchor.x = 1
    s.scale.x = -1
  s


class WallSpritesPool
  constructor: ->
    @windows = @createWindows()
    @decorations = @createDecorations()
    @frontEdges = @createFrontEdges()
    @backEdges = @createBackEdges()
    @steps = @createSteps()

  createWindows: ->
    pool = []
    for name in ["window_01", "window_02"]
      @addToPool pool, 6, name, mkSprite
    @shuffle pool
    pool

  createDecorations: ->
    pool = []
    for name in ["decoration_01", "decoration_02", "decoration_03"]
      @addToPool pool, 6, name, mkSprite
    @shuffle pool
    pool

  createFrontEdges: ->
    pool = []
    for name in ["edge_01", "edge_02"]
      @addToPool pool, 4, name, mkSprite
    @shuffle pool
    pool

  createBackEdges: ->
    pool = []
    for name in ["edge_01", "edge_02"]
      @addToPool pool, 4, name, (name) -> mkSprite(name, flipX:true)
    @shuffle pool
    pool

  createSteps: ->
    pool = []
    @addToPool pool, 2, "step_01", (name) ->
      s = mkSprite(name)
      s.anchor.y = 0.25
      s
    pool


  borrowWindow: -> @windows.shift()
  returnWindow: (sprite) -> @windows.push sprite

  borrowDecoration: -> @decorations.shift()
  returnDecoration: (sprite) -> @decorations.push sprite

  borrowFrontEdge: -> @frontEdges.shift()
  returnFrontEdge: (sprite) -> @frontEdges.push sprite

  borrowBackEdge: -> @backEdges.shift()
  returnBackEdge: (sprite) -> @backEdges.push sprite

  borrowStep: -> @steps.shift()
  returnStep: (sprite) -> @steps.push sprite

  addToPool: (pool, count, name, f) ->
    pool.push f(name) for _ in [1..count]
    null

  shuffle: (array) ->
    len = array.length
    shuffles = len * 3
    for _ in [1..shuffles]
      wallSlice = array.pop()
      pos = Math.floor(Math.random() * (len-1))
      array.splice(pos, 0, wallSlice)

module.exports = WallSpritesPool
