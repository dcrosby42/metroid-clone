
exports.Samus = class Samus
  constructor: ({@motion
                 @action
                 @direction
                 @aim
                 @runSpeed
                 @jumpSpeed
                 @floatSpeed}={}) ->
    @ctype = 'samus'
