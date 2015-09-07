#
# TODO: break refactor this to use a 'generic machine', where the update logic
# is in a ComponentInspectorSystem or something.
# Should be able to do this once I've sorted out what 'generic machine' is, factored out
# from ViewMachine. I think.
class ComponentInspectorMachine
  constructor: ({@componentInspector}) ->

  update: (entityFinder) ->
    entityFinder.allComponentsByCid().forEach (comp) =>
      @componentInspector.update comp
    @componentInspector.sync()
    
module.exports = ComponentInspectorMachine

## This is a copy of the old system, saved for reference:
# ViewSystem = require "../view_system"
#
# class ComponentInspectorSystem extends ViewSystem
#   process: ->
#     @entityFinder.allComponentsByCid().forEach (comp) =>
#       @ui.componentInspector.update comp
#
# module.exports = ComponentInspectorSystem
