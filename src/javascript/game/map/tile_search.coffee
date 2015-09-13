MathUtils = require '../../utils/math_utils'

tileSearch2d = (grid, cellW, cellH, top,left,bottom,right) ->
  hits = []
  minR = minC = 0
  maxR = grid.length - 1
  # maxC = ?? # going off the end of a row won't be a big deal
   
  topR = MathUtils.clamp(Math.floor(top/cellH), minR,maxR)
  bottomR = MathUtils.clamp(Math.floor(bottom/cellH), minR, maxR)
  leftC = Math.floor(left/cellW)
  leftC = 0 if leftC < 0
  rightC = Math.floor(right/cellW)

  for r in [topR..bottomR]
    row = grid[r]
    if row?
      for c in [leftC..rightC]
        hit = grid[r][c]
        if hit?
          hits.push(hit)
  hits

tileSearchVertical = (grid, tw,th, x, topY, bottomY) ->
  hits = []
  c = Math.floor(x/tw)
  for r in [Math.floor(topY/th)..Math.floor(bottomY/th)]
    row = grid[r]
    if row?
      hit = grid[r][c]
      if hit?
        hits.push hit
  hits

tileSearchHorizontal = (grid, tw,th, y, leftX, rightX) ->
  hits = []
  r = Math.floor(y/th)
  row = grid[r]
  if row?
    for c in [Math.floor(leftX/tw)..Math.floor(rightX/tw)]
      hit = grid[r][c]
      if hit?
        hits.push hit
  hits

module.exports =
  search2d: tileSearch2d
  searchHorizontal: tileSearchHorizontal
  searchVertical: tileSearchVertical
