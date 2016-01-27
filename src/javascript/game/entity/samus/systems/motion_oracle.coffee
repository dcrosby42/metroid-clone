
class MotionOracle
  constructor: (motionComp) ->
    @states = motionComp.get('states')

  any:            -> true
  grounded:       -> @states.has('touchingBottom')
  standing:       -> @grounded() and @states.has('xStill')
  running:        -> @grounded() and @movingSideways()
  rising:         -> @states.has('rising')
  falling:        -> @states.has('falling')
  floating:       -> @airborn() and !@spinJumping()
  spinning:       -> @airborn() and @spinJumping()
  movingSideways: -> @states.has('movingSideways')
  airborn:        -> @rising() or @falling()
  spinJumping:    -> false # TODO: boots / suit state for spin jumping?

module.exports = MotionOracle
