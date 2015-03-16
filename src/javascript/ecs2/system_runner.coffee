EntityStoreUpdater = require './entity_store_updater'

searchAndUpdate = (estore, updater, system) ->
  filters = system.getIn ['config','filters']
  update = system.get 'update'
  estore.search(filters).forEach (result) ->
    update(result,updater)


class SystemRunner
  constructor: (@estore, @systems) ->
    @updater = new EntityStoreUpdater(@estore)

  run: ->
    @systems.forEach (system) =>
      # console.log "Runngin system", system.toString()
      switch system.get('type')
        when 'iterating-updating'
          searchAndUpdate @estore, @updater, system
        else
          console.log "!! CAN'T RUN SYSTEM OF TYPE: #{system.get('type')} - #{system.toString()}"


module.exports = SystemRunner

