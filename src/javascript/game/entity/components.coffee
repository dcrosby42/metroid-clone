Immutable = require 'immutable'
imm = Immutable.fromJS

C = {}

C.Position = imm
  type: 'position'
  x: 0
  y: 0

C.Velocity = imm
  type: 'velocity'
  x: 0
  y: 0

C.Gravity = imm
  type: 'gravity'
  accel: 0
  max: 0

C.Animation = imm
  type: 'animation'
  visible: true
  time: 0
  paused: false
  spriteName: null
  layer: null
  state: null

C.Label = imm
  type: 'label'
  content: 'A Label'
  visible: true
  fill_color: 'white'
  font: 'normal 10pt Arial'

C.Name = imm
  type: 'name'
  name: null

C.Controller = imm
  type: 'controller'
  inputName: null
  states: {}

C.Health = imm
  type: 'health'
  hp: 10

C.Death = imm
  type: 'death'
  state: 'new'

C.HitBox = imm
  type: 'hit_box'
  x: 0
  y: 0
  width: 10
  height: 10
  anchorX: 0
  anchorY: 0
  touching:
    left: false
    right: false
    top: false
    bottom: false
  touchingSomething: false

C.Map = imm
  type: 'map'
  name: 'UNSET'

C.MapCollider = imm
  type: 'map_collider'

C.MapGhost = imm
  type: 'map_ghost'
    
C.Sound = imm
  type: 'sound'
  soundId: null
  volume: 0.0
  playPosition: 0.0
  timeLimit: 0
  loop: false
  restart: false
  resound: false

C.Timer = imm
  type: 'timer'
  event: 'timeout'
  time: 0

C.DeathTimer = imm
  type: 'death_timer'
  time: 0

C.Bullet = imm
  type: 'bullet'
  damage: 0

C.Enemy = imm
  type: 'enemy'
  hp: 100

C.Vulnerable = imm
  type: "vulnerable"

C.Harmful = imm
  type: 'harmful'
  damage: 1

C.Damaged = imm
  type: 'damaged'
  state: 'new'
  damage: 1
  impulseX: 0
  impulseY: 0
    
C.HitBoxVisual = imm
  type: 'hit_box_visual'
  color: 0x0000ff
  anchorColor: 0xffffff
  layer: null

C.Tags = imm
  type: 'tags'
  names: Immutable.Set()

C.Pickup = imm
  type: 'pickup'
  item: 'health'
  value: 5

C.Rng = imm
  type: 'rng'
  state: 1234567890

C.ViewportTarget = imm
  type: 'viewport_target'

C.Viewport = imm
  type: 'viewport'
  config:
    width: 0
    height: 0
    trackBufLeft: 0
    trackBufRight: 0
    trackBufTop: 0
    trackBufBottom: 0


C.Hud = imm
  type: 'hud'

C.Ellipse = imm
  type: 'ellipse'
  x: 0
  y: 0
  width: 0
  height: 0
  lineWidth: 1
  lineColor: 0xFFFFFF
  lineAlpha: 1
  fillColor: null
  fillAlpha: 1
  visible: true

C.Rectangle = imm
  type: 'rectangle'
  x: 0
  y: 0
  width: 0
  height: 0
  lineWidth: 1
  lineColor: 0xFFFFFF
  lineAlpha: 1
  fillColor: null
  fillAlpha: 1
  visible: true
    
module.exports = C
