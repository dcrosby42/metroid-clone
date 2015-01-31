C = {}
module.exports = C

C.Position = class Position
  constructor: ({@x,@y}={}) ->
    @ctype = 'position'
    @x ||= 0
    @y ||= 0

C.Velocity = class Velocity
  constructor: ({@x,@y}={}) ->
    @ctype = 'velocity'
    @x ||= 0
    @y ||= 0

C.Gravity = class Gravity
  constructor: ({@accel,@max}) ->
    @ctype = 'gravity'

C.Visual = class Visual
  constructor: ({@spriteName,@state,@time}={}) ->
    @ctype = 'visual'
    @time ||= 0

C.Controller = class Controller
  constructor: ({@inputName,@states}={}) ->
    @ctype = 'controller'
    @states ||= {}

C.HitBox = class HitBox
  constructor: ({@x,@y,@width,@height,@anchorX,@anchorY}={}) ->
    @ctype = 'hit_box'
    @x ||= 0
    @y ||= 0
    @width ||= 10
    @height ||= 10
    @anchorX ||= 0
    @anchorY ||= 0
    @touching ||= {}
    @touching.left ||= false
    @touching.right ||= false
    @touching.top ||= false
    @touching.bottom ||= false
    @touchingSomething = false
    
C.Sound = class Sound
  constructor: ({@soundId,@volume,@playPosition,@timeLimit,@loop,@resound}) ->
    @ctype = 'sound'
    @restart = false
    if !@loop?
      @loop = false

C.DeathTimer = class DeathTimer
  constructor: ({@time}) ->
    @ctype = 'death_timer'

C.Bullet = class Bullet
  constructor: ->
    @ctype = 'bullet'
    

# C.Tags = class Tags
#   constructor: ({@names}) ->
#     @ctype = 'tags'
#     @has = {}
#     for n in @names
#       @has[n] = true
#
