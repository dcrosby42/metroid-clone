Immutable = require 'immutable'
imm = Immutable.fromJS

C = {}
module.exports = C

C.Powerup = imm
  type: 'powerup'
  powerupType: '_UNSET_'

C.Collected = imm
  type: 'collected'
  state: 'ready'
  byEid: '_UNSET_'

C.MaruMari = imm
  type: 'maru_mari'
  state: 'inactive'

C.MissileContainer = imm
  type: 'missile_container'
  state: 'inactive'
