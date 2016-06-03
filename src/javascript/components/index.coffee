Domain = require '../utils/domain'

Types = new Domain('ComponentTypes')

exports.Position = class Position
  Types.registerClass @
  constructor: (@x,@y,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0)
  clone: -> new @constructor(@x,@y,@eid,@cid)
  equals: (o) -> @eid == o.eid and @cid == o.cid and @x == o.x and @y == o.y

exports.Velocity = class Velocity
  Types.registerClass @
  constructor: (@x,@y,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0)
  clone: -> new @constructor(@x,@y,@eid,@cid)
  equals: (o) -> @eid == o.eid and @cid == o.cid and @x == o.x and @y == o.y


exports.Animation = class Animation
  Types.registerClass @
  constructor: (@sprite,@state,@eid,@cid) -> @type = @constructor.type
  @default: -> new @("SPRITE","STATE")
  clone: -> new @constructor(@sprite,@state,@eid,@cid)
  equals: (o) -> @eid == o.eid and @cid == o.cid and @sprite == o.sprite and @state == o.state

exports.Timer = class Timer
  Types.registerClass @
  constructor: (@time,@event,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,"")
  clone: -> new @constructor(@time,@event,@eid,@cid)
  equals: (o) -> @eid == o.eid and @cid == o.cid and @time == o.time

exports.HitBox = class HitBox
  Types.registerClass @
  constructor: (@x,@y,@x2,@y2,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0,0,0)
  clone: -> new @constructor(@x,@y,@x2,@y2,@eid,@cid)
  equals: (o) -> @eid == o.eid and @cid == o.cid and @x == o.x and @y == o.y and @x2 == o.x2 and @y2 == o.y2

exports.Types = Types

ComponentTester = require './component_tester'
ComponentTester.run(exports, types: Types, excused: [ 'Types' ])

