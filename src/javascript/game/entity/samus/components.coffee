
exports.Samus = class Samus
  constructor: ({@motion
                 @action
                 @direction
                 @aim
                 @runSpeed
                 @jumpSpeed
                 @floatSpeed}={}) ->
    @ctype = 'samus'

    @recoil = 'no'
    @weaponTrigger = 'released'
    # @weaponCooldown = null
