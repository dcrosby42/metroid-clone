EntityStore = require '../ecs/entity_store'

#
# TODO: break refactor this to use a 'generic machine', where the update logic
# is in a ComponentInspectorSystem or something.
# Should be able to do this once I've sorted out what 'generic machine' is, factored out
# from ViewMachine. I think.
class ComponentInspectorMachine
  constructor: ({@componentInspector}) ->
    @estore = new EntityStore()

  update: (gameState) ->
    @estore.restoreSnapshot(gameState)
    @estore.allComponentsByCid().forEach (comp) =>
      @componentInspector.update comp
    @componentInspector.sync()

module.exports = ComponentInspectorMachine
