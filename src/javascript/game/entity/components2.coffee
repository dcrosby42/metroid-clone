Immutable = require 'immutable'

C = {}
module.exports = C

C.Position = Immutable.Map
  type: 'position'
  x: 0
  y: 0

C.Velocity = Immutable.Map
  type: 'velocity'
  x: 0
  y: 0

C.Gravity = Immutable.Map
  type: 'gravity'
  accel: 0
  max: 0

C.Visual = Immutable.Map
  type: 'visual'
  time: 0
  spriteName: null
  state: null

C.Controller = Immutable.Map
  type: 'controller'
  inputName: null
  states: {}

C.HitBox = Immutable.Map
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
    
C.Sound = Immutable.Map
  type: 'sound'
  soundId: null
  volume: 0.0
  playPosition: 0.0
  timeLimit: 0
  loop: false
  restart: false
  resound: false

C.DeathTimer = Immutable.Map
  type: 'death_timer'
  time: 0

C.Bullet = Immutable.Map
  type: 'bullet'

C.Enemy = Immutable.Map
  type: 'enemy'
    
C.HitBoxVisual = Immutable.Map
  type: 'hit_box_visual'
  color: 0x0000ff
  anchorColor: 0xffffff

C.Tags = Immutable.Map
  type: 'tags'
  names: Immutable.Set()
