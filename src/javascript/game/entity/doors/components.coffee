Immutable = require 'immutable'
imm = Immutable.fromJS

exports.DoorGel = imm
  type: 'door_gel'
  state: 'closed'

exports.DoorFrame = imm
  type: 'door_frame'
