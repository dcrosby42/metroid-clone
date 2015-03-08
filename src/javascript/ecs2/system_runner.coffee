EntityStoreUpdater = require './entity_store_updater'

class SystemRunner
  constructor: (@estore, @systems) ->
    @updater = new EntityStoreUpdater(@estore)

  run: ->
    @systems.forEach (sys) => @_runSystem @estore, @updater, sys

  _runSystem: (estore, updater, system) ->
    filters = system.getIn ['config','filters']
    update = system.get 'update'

    estore.search(filters).forEach (result) ->
      update(result,updater)

module.exports = SystemRunner

