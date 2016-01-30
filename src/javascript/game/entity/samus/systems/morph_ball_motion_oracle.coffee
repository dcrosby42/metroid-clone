
class MorphBallMotionOracle
  constructor: (motionComp) ->
    @states = motionComp.get('states')

  any:            -> true
  grounded:       -> @states.has('touchingBottom')
  underSomething: -> @states.has('adjacentTop')
  inTheClear:     -> @grounded() and !@underSomething()
  # parked:         -> @grounded() and @states.has('xStill')
  # rolling:        -> @grounded() and @movingSideways()
  # rising:         -> @states.has('rising')
  # falling:        -> @states.has('falling')
  # movingSideways: -> @states.has('movingSideways')
  # airborn:        -> @rising() or @falling()

module.exports = MorphBallMotionOracle
