Immutable = require 'immutable'
imm = Immutable.fromJS

C = {}
module.exports = C

C.Pickup = imm
  type: 'pickup'
  itemType: null
  itemId: null
  data: null

# C.Powerup = imm
#   type: 'powerup'
#   powerupType: '_UNSET_'

C.PowerupCelebration = imm
  type: 'powerup_celebration'

C.MaruMari = imm
  type: 'maru_mari'
  state: 'inactive'

C.MissileContainer = imm
  type: 'missile_container'
  state: 'inactive'

C.MissileLauncher = imm
   type: 'missile_launcher'
   max: 0
   count: 0
