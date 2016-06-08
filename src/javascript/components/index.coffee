_ = require 'lodash'
Domain = require '../utils/domain'

Types = new Domain('ComponentTypes')

exports.Position = class Position
  Types.registerClass @
  constructor: (@x,@y,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0)
  clone: -> new @constructor(@x,@y,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @x == o.x and @y == o.y

# FIXME
exports.Velocity = class Velocity
  Types.registerClass @
  constructor: (@x,@y,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0)
  clone: -> new @constructor(@x,@y,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @x == o.x and @y == o.y

exports.MainTitle = class MainTitle
  Types.registerClass @
  constructor: (@state,@eid,@cid) -> @type = @constructor.type
  @default: -> new exports.MainTitle('begin')
  clone: -> new @constructor(@state,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @state == o.state

exports.Controller = class Controller
  Types.registerClass @
  constructor: (@inputName,@states,@eid,@cid) -> @type = @constructor.type
  @default: -> new @('UNSET',{})
  clone: -> new @constructor(@inputName,@states,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @inputName == o.inputName and _.isEqual(@states,o.states)

exports.Expire = class Expire
  Types.registerClass @
  constructor: (@eid,@cid) -> @type = @constructor.type
  @default: -> new @()
  clone: -> new @constructor(@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid

exports.Label = class Label
  Types.registerClass @
  constructor: (@content,@layer,@eid,@cid) -> @type = @constructor.type
  @default: -> new @('A Label','a_layer')
  clone: -> new @constructor(@content,@layer,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @content == o.content and @layer == o.layer

exports.Name = class Name
  Types.registerClass @
  constructor: (@name,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(@name)
  clone: -> new @constructor(@name,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @name == o.name

exports.Viewport = class Viewport
  Types.registerClass @
  constructor: (@width,@height,@trackBufLeft,@trackBufRight,@trackBufTop,@trackBufBottom,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(@name)
  clone: -> new @constructor(@width,@height,@trackBufLeft,@trackBufRight,@trackBufTop,@trackBufBottom,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @name == o.name

# FIXME
exports.Animation = class Animation
  Types.registerClass @
  constructor: (@spriteName,@state,@eid,@cid) -> @type = @constructor.type
  @default: -> new @("SPRITE","STATE")
  clone: -> new @constructor(@spriteName,@state,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @spriteName == o.spriteName and @state == o.state

# FIXME
exports.Timer = class Timer
  Types.registerClass @
  constructor: (@time,@eventName,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,"UNSET")
  clone: -> new @constructor(@time,@eventName,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @time == o.time and @eventName == o.eventName

# FIXME
exports.HitBox = class HitBox
  Types.registerClass @
  constructor: (@x,@y,@x2,@y2,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0,0,0)
  clone: -> new @constructor(@x,@y,@x2,@y2,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @x == o.x and @y == o.y and @x2 == o.x2 and @y2 == o.y2


exports.Types = Types

ComponentTester = require './component_tester'
ComponentTester.run(exports, types: Types, excused: [ 'Types' ])

