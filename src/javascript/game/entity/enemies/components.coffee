Immutable = require 'immutable'
imm = Immutable.fromJS

C = {}
module.exports = C

C.Skree = imm
  type: 'skree'
  action: 'sleep'
  direction: 'neither'
  strafeSpeed: 50/1000
  triggerRange: 32


