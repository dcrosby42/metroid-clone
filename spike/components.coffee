Domain = require './domain'

Types = new Domain('ComponentTypes')

exports.Position = class Position
  constructor: (@x=0,@y=0,@eid,@cid) ->

  clone: -> @constructor(@x,@y,@eid,@cid)

Types.registerClass Position

exports.Animation = class Animation
  constructor: (@sprite,@state,@eid,@cid) ->

  clone: -> @constructor(@sprite,@state,@eid,@cid)

Types.registerClass Animation

# p1 = new Position()
# console.log p1
#
# a = new Animation()
# console.log a
