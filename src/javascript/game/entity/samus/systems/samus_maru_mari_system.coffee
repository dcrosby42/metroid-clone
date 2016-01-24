BaseSystem = require '../../../../ecs/base_system'
# Common = require '../../components'
# Immutable = require 'immutable'
# StateMachineSystem = require '../../../../ecs/state_machine_system'

class SamusMaruMariSystem extends BaseSystem
  @Subscribe: ['maru_mari', 'samus', 'controller']

  process: ->
    ctrl = @getProp 'controller', 'states'
    samus = @getComp('samus')
    
    action = switch samus.get('motion')
      when 'standing'
        if ctrl.get('downPressed')
          console.log "BALL UP"

module.exports = SamusMaruMariSystem
