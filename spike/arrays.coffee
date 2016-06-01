# chai = require('chai')
# expect = chai.expect
# assert = chai.assert
# expectIs = require('../helpers/expect_helpers').expectIs
#
# describe "a", ->
#   it "thing", ->
#     expect(true).to.eq(true)

UNSET = "UNSET"

Types =
  Animation: 1
  Position: 2

Position = (eid,cid,x,y) ->
  { type: Types.Position, eid: eid, cid: cid, x: x, y: y, clone: Position.clone, defaults: Position.defaults }

Position.clone = ->
  Position(@eid,@cid,@x,@y)

Position.defaults = ->
  @x = 0.0
  @y = 0.0
  @
  
exports.Position = Position


Animation = (eid,cid,sprite,state,time) ->
  { type: Types.Animation, eid: eid, cid: cid, sprite: sprite, state: state, time: time, clone: Animation.clone, defaults: Animation.defaults }

Animation.clone = ->
  Animation(@eid,@cid,@sprite,@state,@time)

Animation.defaults = ->
  @eid = 0
  @cid = 0
  @sprite = UNSET
  @state = UNSET
  @time = 0.0
  @
  


exports.Animation = Animation

S =
  Samus:
    Sprite: "samus"
    State:
      RunRight: 1
      RunLeft: 2

anim1 = Animation(1,1)
anim1.sprite = S.Samus.Sprite
anim1.state = S.Samus.State.RunRight
anim1.time = S.Samus.State.RunRight

anim2 = anim1.clone()
anim2.state = S.Samus.State.RunLeft
console.log anim1
console.log anim2

anim3 = Animation().defaults()
console.log anim3


# comp = [0,0,0,0]
# comp[T.Eid] = 1
# comp[T.Cid] = T.Position.Type
# comp[T.X] = 42.42
# comp[T.Y] = -37.69


