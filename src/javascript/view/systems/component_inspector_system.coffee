ViewSystem = require "../view_system"

class ComponentInspectorSystem extends ViewSystem
  process: ->
    @entityFinder.allComponentsByCid().forEach (comp) =>
      @ui.componentInspector.update comp

module.exports = ComponentInspectorSystem
