
class Motions
  constructor: ->
    @rising = false
    @falling = false
    @yStill = false
    @touching = false
    @touchingBottom = false
    @touchingTop = false
    @adjacent = false
    @adjacentTop = false
    @movingSideways = false
    @movingRight = false
    @movingLeft = false
    @xStill = false

  @default: -> new @()

  clone: ->
    cloned = new @constructor()
    cloned.rising = @rising
    cloned.falling = @falling
    cloned.yStill = @yStill
    cloned.touching = @touching
    cloned.touchingBottom = @touchingBottom
    cloned.touchingTop = @touchingTop
    cloned.adjacent = @adjacent
    cloned.adjacentTop = @adjacentTop
    cloned.movingSideways = @movingSideways
    cloned.movingRight = @movingRight
    cloned.movingLeft = @movingLeft
    cloned.xStill = @xStill
    cloned

  equals: (o) ->
    o? and
       @rising == o.rising and
       @falling == o.falling and
       @yStill == o.yStill and
       @touching == o.touching and
       @touchingBottom == o.touchingBottom and
       @touchingTop == o.touchingTop and
       @adjacent == o.adjacent and
       @adjacentTop == o.adjacentTop and
       @movingSideways == o.movingSideways and
       @movingRight == o.movingRight and
       @movingLeft == o.movingLeft and
       @xStill == o.xStill

  oracle: -> new SuitOracle(@)
  morphBallOracle: -> new MorphBallOracle(@)

class SuitOracle
  constructor: (@motions) ->

  any:            -> true
  grounded:       -> @motions.touchingBottom
  standing:       -> @grounded() and @motions.xStill
  running:        -> @grounded() and @movingSideways()
  rising:         -> @motions.rising
  falling:        -> @motions.falling
  floating:       -> @airborn() and !@spinJumping()
  spinning:       -> @airborn() and @spinJumping()
  movingSideways: -> @motions.movingSideways
  airborn:        -> @rising() or @falling()
  spinJumping:    -> false # TODO: boots / suit state for spin jumping?

class MorphBallOracle
  constructor: (@motions) ->
    # @states = motionComp.get('states')

  any:            -> true
  grounded:       -> @motions.touchingBottom
  underSomething: -> @motions.adjacentTop
  inTheClear:     -> @grounded() and !@underSomething()
  # parked:         -> @grounded() and @motions.xStill
  # rolling:        -> @grounded() and @movingSideways()
  # rising:         -> @motions.rising
  # falling:        -> @motions.falling
  # movingSideways: -> @motions.movingSideways
  # airborn:        -> @rising() or @falling()


ComponentTester = require './component_tester'
ComponentTester.SubComponent.runSingle(Motions)

module.exports = Motions
