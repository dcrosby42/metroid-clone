class Point
  constructor: (@x,@y,@eid,@cid) ->
    @type = 5
    null

  clone: ->
    new @constructor(@x,@y,@eid,@cid)

  replicate: ->
    @constructor(@x,@y,null,null)

  @default: ->
    @(0.0,0.0,null,null)

class Component
  constructor: (@eid,@cid) ->

  replicate: ->
    r = @clone()
    r.eid = null
    r.cid = null
    r

class PointC extends Component
  constructor: (@x,@y,eid,cid) ->
    @super(eid,cid)
    @type = 5

  clone: ->
    new @constructor(@x,@y,@eid,@cid)

  @default: ->
    @(0.0,0.0,null,null)
  
point2Clone = ->
  Point2(@x,@y,@eid,@cid)

point2Replicate = ->
  Point2(@x,@y,null,null)

Point2 = (x,y,eid,cid) ->
  {
    type: 5
    eid: 0
    cid: 0
    x: x
    y: y
    clone: point2Clone
    replicate: point2Replicate
  }
defaultPoint2 = ->
  Point2(0.0,0.0,null,null)


Benchmark = require 'benchmark'
suite = new Benchmark.Suite

p1 = new Point(42,42)
p2 = Point2(53,53)

suite.add "new Point()", ->
  x = new Point(100,100)
  null

suite.add "Point.clone()", ->
  x = p1.clone()
  null

suite.add "Point.replicate()", ->
  x = p1.replicate()
  null

suite.add "Point.defaults()", ->
  x = p1.defaults()
  null

suite.add "new PointC()", ->
  x = new PointC(100,100)
  null

suite.add "PointC.clone()", ->
  x = p2.clone()
  null

suite.add "PointC.replicate()", ->
  x = p2.replicate()
  null

suite.add "Point2.defaults()", ->
  x = p2.defaults()
  null

suite.add "Point2()", ->
  x = Point2(100,100)

suite.add "Point2.clone()", ->
  x = p2.clone()
  null

suite.add "Point2.replicate()", ->
  x = p2.replicate()
  null

suite.add "defaultPoint2()", ->
  x = defaultPoint2()
  null

suite.on 'complete', ->
  console.log('Fastest is ' + @filter('fastest').map('name'))
  # console.log @

suite.on 'cycle', (event) ->
    console.log String(event.target)


suite.run(async:true)
