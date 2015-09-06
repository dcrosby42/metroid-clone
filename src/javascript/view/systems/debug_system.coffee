ViewSystem = require "../view_system"

class DebugSystem extends ViewSystem
  process: ->
    @entityFinder.allComponentsByCid().forEach (comp) =>
      @ui.componentInspector.update comp

module.exports = DebugSystem

