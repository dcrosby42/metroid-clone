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
  constructor: (@content,@layer,@visible,@font,@fill_color,@eid,@cid) -> @type = @constructor.type
  @default: -> new @('LABEL','LAYER',true,'normal 10pt Arial','white')
  clone: -> new @constructor(@content,@layer,@visible,@font,@fill_color,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @content == o.content and @layer == o.layer and @visible == o.visible and @font == o.font and @fill_color == o.fill_color

exports.Name = class Name
  Types.registerClass @
  constructor: (@name,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(@name)
  clone: -> new @constructor(@name,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @name == o.name

exports.Viewport = class Viewport
  Types.registerClass @
  constructor: (@width,@height,@trackBufLeft,@trackBufRight,@trackBufTop,@trackBufBottom,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0, 0,0,0,0)
  clone: -> new @constructor(@width,@height,@trackBufLeft,@trackBufRight,@trackBufTop,@trackBufBottom,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @width == o.width and @height == o.height and @trackBufLeft == o.trackBufLeft and @trackBufRight == o.trackBufRight and @trackBufTop == o.trackBufTop and @trackBufBottom == o.trackBufBottom

exports.Animation = class Animation
  Types.registerClass @
  constructor: (@spriteName,@state,@layer,@time,@paused,@visible,@eid,@cid) -> @type = @constructor.type
  @default: -> new @("SPRITE","STATE","LAYER",0.0,false,true)
  clone: -> new @constructor(@spriteName,@state,@layer,@time,@paused,@visible,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @spriteName == o.spriteName and @state == o.state and @layer == o.layer and @time == o.time and @paused == o.paused and @visible == o.visible

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

#
# Auto-tests for components to catch typos etc:
#
ComponentTester = require './component_tester'
ComponentTester.run(exports, types: Types, excused: [ 'Types' ])

