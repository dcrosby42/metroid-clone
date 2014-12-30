SliceType = require './slice_type'
Walls = require './walls'

class MapBuilder
  constructor: ->

  createWalls: (mapData) ->
    walls = new Walls()
    for sliceItems in (MapBuilder.convertMapItem mapItem for mapItem in mapData)
      for [sliceType, y] in sliceItems
        walls.addSlice sliceType, y
    walls

  @CONVERTERS:
    gap: ([_,length]) ->
      length ?= 1
      for i in [0...length]
        [SliceType.GAP, null]

    wall: ([_,{level,length,noBack,noFront}]) ->
      noBack ?= false
      noFront ?= false
      y = MapBuilder.yForLevel(level)
      ret = []
      if !noFront and length > 0
        ret.push [SliceType.FRONT, y]
        length -= 1

      midLength = length - (if noBack then 0 else 1)
      for i in [0...midLength]
        sliceType = if i % 2 == 0
          SliceType.WINDOW
        else
          SliceType.DECORATION
        ret.push [sliceType, y]
      length -= midLength

      if !noBack and length > 0
        ret.push [SliceType.BACK, y]

      ret

    stepWall: ([_,{level,leftLength,rightLength}]) ->
      level ?= 3
      leftLength ?= 5
      rightLength ?= 5
      level = 2 if level < 2
      level2 = level - 2

      slices = MapBuilder.convertMapItem(['wall', {level: level, length: leftLength, noBack:true}])
      slices.push [SliceType.STEP, MapBuilder.yForLevel(level2)]
      for s in MapBuilder.convertMapItem(['wall', {level: level2, length: rightLength, noFront:true}])
        slices.push s
      slices


  @convertMapItem: (item) ->
    if conv = MapBuilder.CONVERTERS[item[0]]
      conv(item)
    else
      [ item ]

  @WALL_HEIGHTS = [
    256 # 0: Lowest slice
    224
    192
    160
    128 # 4: Highest slice
  ]

  @yForLevel: (level) -> MapBuilder.WALL_HEIGHTS[level]
    
module.exports = MapBuilder
window.MapBuilder = MapBuilder
