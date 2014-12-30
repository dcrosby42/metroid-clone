
exports.Samus = class Samus
  constructor: ({@action
                 @direction
                 @aim
                 @runSpeed
                 @jumpSpeed
                 @floatSpeed}={}) ->
    @ctype = 'samus'
