Common = require '../../components'
Immutable = require 'immutable'
StateMachineSystem = require '../../../../ecs/state_machine_system'

class PowerupCollectionSystem extends StateMachineSystem
  @Subscribe: ['collected','powerup']

  @StateMachine:
    componentProperty: ['collected','state']
    start: 'ready'
    states:
      ready:
        events:
          started:
            action: 'celebrate'
            nextState: 'songing'
      songing:
        events:
          partyOver:
            action:    'installPowerup'
            nextState: 'done'
      done: {}

  shortcutState: ->
    @installPowerupAction()

  readyState: ->
    @publishEvent 'started'

  celebrateAction: ->
    @addComp Common.Sound.merge
      soundId: 'powerup_jingle'
      volume: 0.5
      playPosition: 0
      timeLimit: 4500
    @addComp Common.Timer.merge
      time: 4500
      event: 'partyOver'

  installPowerupAction: ->
    powerup = @getComp 'powerup'
    # Grab the relevant powerup item (assumed to have the ctype matching powerupType field)
    item = @getEntityComponent(@eid(), powerup.get('powerupType'))
    heroEid = @getProp 'collected', 'byEid'
    # Install item in player entity:
    @addEntityComp heroEid, item
    
    # Remove the powerup's entity:
    @destroyEntity()

    @publishGlobalEvent 'PowerupInstalled'


module.exports = PowerupCollectionSystem

