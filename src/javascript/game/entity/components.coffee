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

C.Visual = imm
  type: 'visual'
  time: 0
  spriteName: null
  layer: null
  state: null

C.Controller = imm
  type: 'controller'
  inputName: null
  states: {}

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
    
C.Sound = imm
  type: 'sound'
  soundId: null
  volume: 0.0
  playPosition: 0.0
  timeLimit: 0
  loop: false
  restart: false
  resound: false

C.DeathTimer = imm
  type: 'death_timer'
  time: 0

C.Bullet = imm
  type: 'bullet'

C.Enemy = imm
  type: 'enemy'
    
C.HitBoxVisual = imm
  type: 'hit_box_visual'
  color: 0x0000ff
  anchorColor: 0xffffff
  layer: null

C.Tags = imm
  type: 'tags'
  names: Immutable.Set()

module.exports = C
