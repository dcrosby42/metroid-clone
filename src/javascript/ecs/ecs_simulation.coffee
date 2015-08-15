Immutable = require 'immutable'
EventBucket = require './event_bucket'
EntityStoreUpdater = require './entity_store_updater'

class EcsSimulation
  constructor: ({systems}) ->
    @systems = Immutable.List(systems)
    @systemInstances = @systems.map (s) -> s.Instance()

    @eventBucket = new EventBucket()
    @entityStoreUpdater = new EntityStoreUpdater()

  update: (estore, input) ->
    @eventBucket.reset()
    @entityStoreUpdater.setEntityStore(estore)

    @systemInstances.forEach (s) =>
      estore.search(s.componentFilters).forEach (comps) =>
        s.handleUpdate(comps, input, @entityStoreUpdater, @eventBucket)

    @entityStoreUpdater.unsetEntityStore()
    null

module.exports = EcsSimulation

