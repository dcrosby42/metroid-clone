Immutable = require 'immutable'
EventBucket = require './event_bucket'
EntityStore = require './entity_store'
Config = require '../config'

class EcsMachine
  constructor: ({systems}) ->
    @systemDefs = systems
    @systems = Immutable.List(@systemDefs).map (s) -> s.Instance()

    @eventBucket = new EventBucket()
    @estore = new EntityStore()

  # update3: (estore, input) ->
  #   [events,_syslogs] = @update(estore,input)
  #   return events

  update: (gameState, input) ->
    @eventBucket.reset()
    @estore.restoreSnapshot(gameState)

    systemLogs = if Config.system_log.enabled
      {}
    else
      null

    @systems.forEach (system) =>
      systemLog = null
      if systemLogs?
        systemLog = {}
        systemLogs[system.constructor.name] = systemLog
      system.update(@estore, input, @eventBucket, systemLog)

    gameState1 = @estore.takeSnapshot()

    return [gameState1,@eventBucket.globalEvents,systemLogs]

  # update2: (state, input) ->
  #   @eventBucket.reset()
  #   @estore.restoreSnapshot(state)
  #
  #   @systems.forEach (system) =>
  #     system.update(@estore, input, @eventBucket)
  #
  #   events = @eventBucket.globalEvents
  #   state1 = @estore.takeSnapshot()
  #   return [state1, events]

module.exports = EcsMachine

