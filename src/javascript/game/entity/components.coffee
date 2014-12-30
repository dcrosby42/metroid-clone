C = {}
module.exports = C

C.Position = class Position
  constructor: ({@x,@y}={}) ->
    @ctype = 'position'
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

C.Samus = class Samus
  constructor: ({@action,@direction,@aim,@runSpeed}={}) ->
    @ctype = 'samus'
