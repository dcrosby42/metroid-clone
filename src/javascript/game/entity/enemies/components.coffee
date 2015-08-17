Immutable = require 'immutable'
imm = Immutable.fromJS

C = {}
module.exports = C

C.Skree = imm
  type: 'skree'
  action: 'sleeping'
  strafeSpeed: 50/1000
  max_hp: 10
  triggerRange: 32

C.Zoomer = imm
  type: 'zoomer'
  orientation: 'up'

C.Crawl = imm
  type: 'crawl'
