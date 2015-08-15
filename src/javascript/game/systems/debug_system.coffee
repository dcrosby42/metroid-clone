
module.exports =
  systemType: 'output'

  update: (entityFinder,ui) ->
    entityFinder.allComponentsByCid().forEach (comp) ->
        ui.componentInspector.update comp
