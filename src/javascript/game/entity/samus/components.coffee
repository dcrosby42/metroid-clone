Immutable = require 'immutable'

exports.Samus = Immutable.fromJS
  type: 'samus'
  action: null
  motion: 'standing' # standing | running | jumping | falling
  direction: 'right' # right | left
  aim: 'straight' # up | straight
  runSpeed: 88/1000 # 88 px/sec
  jumpSpeed: 400/1000

  floatSpeed: 60/1000
  recoil: 'no'
  weaponTrigger: 'released'

exports.ShortBeam = Immutable.fromJS
  type: 'short_beam'
  state: 'ready'
  damage: 5
  cooldown: 0

exports.Suit = Immutable.fromJS
  type: 'suit'

