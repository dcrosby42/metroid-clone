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

C.Movement = class Movement
  constructor: ({@x,@y}={}) ->
    @ctype = 'movement'
    @x ||= 0
    @y ||= 0

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
    
