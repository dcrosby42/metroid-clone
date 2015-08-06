Immutable = require 'immutable'
imm = Immutable.fromJS

C = {}
module.exports = C

C.Skree = imm
  type: 'skree'
  action: 'sleep'
  direction: 'neither'
  strafeSpeed: 50/1000
  max_hp: 10
  triggerRange: 32
