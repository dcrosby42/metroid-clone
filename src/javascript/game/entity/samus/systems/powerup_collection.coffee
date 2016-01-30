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

  readyState: ->
    @publishEvent 'started'

  celebrateAction: ->
    @addComp Common.Sound.merge
      soundId: 'powerup_jingle'
      volume: 0.2
      playPosition: 0
      timeLimit: 750
    @addComp Common.Timer.merge
      time: 750
      event: 'partyOver'

  installPowerupAction: ->
    console.log "installPowerupAction: powerupEid: #{@eid()}"
    powerup = @getComp 'powerup'
    console.log "installPowerupAction:   powerup:", powerup.toJS()
    item = @getEntityComponent(@eid(), powerup.get('powerupType'))
    console.log "installPowerupAction:   item:", item.toJS()

    
    # Grab the relevant powerup item (assumed to have the ctype matching powerupType field)
    item = @getEntityComponent(@eid(), powerup.get('powerupType'))
    heroEid = @getProp 'collected', 'byEid'
    # Install item in player entity:
    @addEntityComp heroEid, item
    console.log "installPowerupAction:   item installed into heroEid #{heroEid}"
    
    # Remove the powerup's entity:
    @destroyEntity()

    @publishGlobalEvent 'PowerupInstalled'


module.exports = PowerupCollectionSystem

