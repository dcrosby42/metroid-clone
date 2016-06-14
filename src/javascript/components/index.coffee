_ = require 'lodash'
Domain = require '../utils/domain'
Motions = require './motions'

Types = new Domain('ComponentTypes')

exports.Position = class Position
  Types.registerClass @
  constructor: (@x,@y,@name,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0,null)
  clone: -> new @constructor(@x,@y,@name,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @x == o.x and @y == o.y and @name == o.name

exports.Velocity = class Velocity
  Types.registerClass @
  constructor: (@x,@y,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0)
  clone: -> new @constructor(@x,@y,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @x == o.x and @y == o.y

exports.Gravity = class Gravity
  Types.registerClass @
  constructor: (@accel,@max,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0)
  clone: -> new @constructor(@accel,@max,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @accel == o.accel and @max == o.max

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

exports.Tag = class Tag
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

exports.ViewportShuttle = class ViewportShuttle
  Types.registerClass @
  constructor: (@destArea,@thenTarget,@eid,@cid) -> @type = @constructor.type
  @default: -> new @('DEST_AREA','THEN_TARGET')
  clone: -> new @constructor(@destArea,@thenTarget,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @destArea == o.destArea and @thenTarget == o.thenTarget

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

exports.HitBox = class HitBox
  Types.registerClass @
  constructor: (@x,@y,@width,@height,@anchorX,@anchorY,@touching,@touchingSomething,@adjacent,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0,0,0,0.5,0.5, Touching.default(), false, Touching.default())
  clone: -> new @constructor(@x,@y,@width,@height,@anchorX,@anchorY,@touching.clone(),@touchingSomething,@adjacent.clone(),@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @x == o.x and @y == o.y and @width == o.width and @height == o.height and @anchorX == o.anchorX and @anchorY == o.anchorY and @touching.equals(o.touching) and @touchingSomething == o.touchingSomething and @adjacent.equals(o.adjacent)

  @Touching: class Touching
    constructor: (@left,@right,@top,@bottom) ->
    @default: -> new @(false,false,false,false)
    clone: -> new @constructor(@left,@right,@top,@bottom)
    equals: (o) -> o? and @left == o.left and @right == o.right and @top == o.top and @bottom == o.bottom

exports.HitBoxVisual = class HitBoxVisual
  Types.registerClass @
  constructor: (@color,@anchor_color,@layer,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0x0000ff,0xffffff,"LAYER")
  clone: -> new @constructor(@color,@anchor_color,@layer,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @color == o.color and @anchor_color == o.anchor_color and @layer == o.layer

exports.Suit = class Suit
  Types.registerClass @
  constructor: (@pose,@direction,@aim,@runSpeed,@jumpSpeed,@floatSpeed,@eid,@cid) -> @type = @constructor.type
  @default: -> new @('POSE','DIRECTION','AIM',0.0,0.0,0.0)
  clone: -> new @constructor(@pose,@direction,@aim,@runSpeed,@jumpSpeed,@floatSpeed,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @pose == o.pose and @direction == o.direction and @aim == o.aim and @runSpeed == o.runSpeed and @jumpSpeed == o.jumpSpeed and @floatSpeed == o.floatSpeed

exports.Health = class Health
  Types.registerClass @
  constructor: (@hp,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0)
  clone: -> new @constructor(@hp,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @hp == o.hp

exports.Motion = class Motion
  Types.registerClass @
  constructor: (@motions,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(Motions.default())
  clone: -> new @constructor(@motions.clone(),@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @motions.equals(o.motions)

exports.CollectedItems = class CollectedItems
  Types.registerClass @
  constructor: (@itemIds,@eid,@cid) -> @type = @constructor.type
  @default: -> new @([])
  clone: -> new @constructor(@itemIds,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and _.isEqual(@itemIds, o.itemIds)

exports.Room = class Room
  Types.registerClass @
  constructor: (@roomId,@roomType,@state,@roomCol,@roomRow,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,'ROOMTYPE','ROOMSTATE',0,0)
  clone: -> new @constructor(@roomId,@roomType,@state,@roomCol,@roomRow,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @roomId == o.roomId and @roomType == o.roomType and @state == o.state and @roomCol == o.roomCol and @roomRow == o.roomRow

exports.RoomWatcher = class RoomWatcher
  Types.registerClass @
  constructor: (@roomIds,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(new Array(10))
  clone: -> new @constructor(@roomIds,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and _.isEqual(@roomIds, o.roomIds)

exports.Rng = class Rng
  Types.registerClass @
  constructor: (@state,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(1)
  clone: -> new @constructor(@state,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @state == o.state

exports.Damaged = class Damaged
  Types.registerClass @
  constructor: (@state,@damage,@impulseX,@impulseY,@eid,@cid) -> @type = @constructor.type
  @default: -> new @('new',1,0.0,0.0)
  clone: -> new @constructor(@state,@damage,@impulseX,@impulseY,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @state == o.state and @damage == o.damage and @impulseX == o.impulseX and @impulseY == o.impulseY

exports.Sound = class Sound
  Types.registerClass @
  constructor: (@soundId,@volume,@playPosition,@timeLimit,@loop,@restart,@resound,@eid,@cid) -> @type = @constructor.type
  @default: -> new @('SOUND',1.0,1.0,0,false,false,false)
  clone: -> new @constructor(@soundId,@volume,@playPosition,@timeLimit,@loop,@restart,@resound,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @soundId == o.soundId and @volume == o.volume and @playPosition == o.playPosition and @timeLimit == o.timeLimit and @loop == o.loop and @restart == o.restart and @resound == o.resound

exports.Types = Types

# exports.buildComp = (clazz,obj=null) ->
#   comp = clazz.default()
#   Object.assign comp, obj if obj?
#   comp

exports.buildCompForType = (typeid,obj=null) ->
  comp = Types.classFor(typeid).default()
  Object.assign comp, obj if obj?
  comp
  
# console.log exports.buildCompForType(Types.Position)

#
# Auto-tests for components to catch typos etc:
#
ComponentTester = require './component_tester'
ComponentTester.run(exports, types: Types, excused: [ 'Types', 'buildCompForType' ])

